//
//  MovieSession.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import AVFoundation
import AVKit
import Combine

// TODO: Update this class to use the new observation framework.
final class MovieSession: ObservableObject {
    let movie: Movie
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var pictureInPicture: PictureInPicture?
    private var pictureInPictureCancellable: AnyCancellable?
    var playbackRestorer: PictureInPicturePlaybackRestorer?
    
    @Published
    private(set) var state: State = .idle
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    @MainActor
    func loadVideo() async {
        state = .loading
        
        debugPrint("Loading player for asset(\(movie.url)).")
        
        do {
            let player = AVPlayer(url: movie.url)
            self.player = player
            
            guard let isPlayable = try await player.currentItem?.asset.load(.isPlayable),
                  isPlayable else {
                debugPrint("Asset is not playable.")
                state = .failed
                clearResources()
                return
            }
            
            let playerLayer = AVPlayerLayer(player: player)
            self.playerLayer = playerLayer
            
            let pictureInPicture = await PictureInPicture(playerLayer: playerLayer)
            bindToUpdates(in: pictureInPicture)
            pictureInPicture.playbackRestorer = playbackRestorer
            self.pictureInPicture = pictureInPicture
            
            state = .loaded(playerLayer: playerLayer, pictureInPicture: pictureInPicture)
        } catch {
            debugPrint("Asset couldn't be loaded -> \(error).")
            state = .failed
            clearResources()
        }
    }
    
    func startPlayback() {
        if player?.status == .readyToPlay {
            debugPrint("Starting playback.")
            player?.play()
        } else {
            debugPrint("Couldn't start playback. Player is not ready.")
        }
    }
    
    func stopPlayback() {
        player?.pause()
    }
    
    private func bindToUpdates(in pictureInPicture: PictureInPicture) {
        pictureInPictureCancellable = pictureInPicture
            .$state
            .map { _ in () }
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
    }
    
    private func clearResources() {
        player = nil
        playerLayer = nil
        pictureInPicture = nil
        pictureInPictureCancellable = nil
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
