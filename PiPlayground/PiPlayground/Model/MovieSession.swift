//
//  MovieSession.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import AVFoundation
import AVKit
import OSLog

@Observable final class MovieSession {
    let movie: Movie
    var playbackRestorer: PictureInPicturePlaybackRestorer?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var pictureInPicture: PictureInPicture?
    private let logger = Logger(category: .movieSession)
    
    private(set) var state: State = .idle
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    @MainActor
    func loadVideo() async {
        state = .loading
        
        logger.debug("Loading player for \(self.movie)")
        
        do {
            let player = AVPlayer(url: movie.url)
            self.player = player
            
            guard let isPlayable = try await player.currentItem?.asset.load(.isPlayable),
                  isPlayable else {
                logger.error("Mvoie asset is not playable: \(self.movie)")
                state = .failed
                clearResources()
                return
            }
            
            let playerLayer = AVPlayerLayer(player: player)
            self.playerLayer = playerLayer
            
            let pictureInPicture = await PictureInPicture(playerLayer: playerLayer)
            pictureInPicture.playbackRestorer = playbackRestorer
            self.pictureInPicture = pictureInPicture
            
            state = .loaded(playerLayer: playerLayer, pictureInPicture: pictureInPicture)
        } catch {
            logger.error("Movie asset could not be loaded: \(error), movie: \(self.movie)")
            state = .failed
            clearResources()
        }
    }
    
    func startPlayback() {
        if player?.status == .readyToPlay {
            logger.debug("Starting movie playback")
            player?.play()
        } else {
            logger.debug("Couldn't start playback. Player is not ready")
        }
    }
    
    func stopPlayback() {
        player?.pause()
    }
    
    private func clearResources() {
        player = nil
        playerLayer = nil
        pictureInPicture = nil
    }
}

extension MovieSession {
    enum State {
        case idle
        case loading
        case loaded(playerLayer: AVPlayerLayer, pictureInPicture: PictureInPicture)
        case failed
    }
}

extension MovieSession: Hashable {
    static func == (lhs: MovieSession, rhs: MovieSession) -> Bool {
        lhs.movie == rhs.movie
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(movie.hashValue)
    }
}
