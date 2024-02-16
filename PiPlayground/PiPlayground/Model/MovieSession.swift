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
                return
            }
            
            let playerLayer = AVPlayerLayer(player: player)
            self.playerLayer = playerLayer
            
            let pictureInPicture = await PictureInPicture(playerLayer: playerLayer)
            self.pictureInPicture = pictureInPicture
            
            state = .loaded(
                player: player,
                playerLayer: playerLayer,
                pictureInPicture: pictureInPicture
            )
        } catch {
            debugPrint("Asset couldn't be loaded -> \(error).")
            state = .failed
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
}

extension MovieSession {
    enum State {
        case idle
        case loading
        case loaded(player: AVPlayer, playerLayer: AVPlayerLayer, pictureInPicture: PictureInPicture)
        case failed
    }
}
