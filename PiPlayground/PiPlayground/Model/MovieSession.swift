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
    private(set) var pictureInPicture: PictureInPicture?
    private var player: AVPlayer?
    
    @Published
    private(set) var state: State = .idle
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    @MainActor
    func loadVideo() async {
        state = .loading
        
        debugPrint("Loading player for asset(\(movie.url)).")
        let player = AVPlayer(url: movie.url)
        
        do {
            guard let isPlayable = try await player.currentItem?.asset.load(.isPlayable), isPlayable else {
                debugPrint("Asset is not playable.")
                state = .failed
                return
            }
            self.player = player
            state = .loaded(player: player)
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
    
    func setupPictureInPicture(using layer: AVPlayerLayer) {
        debugPrint("Pip is being setup.")
        guard pictureInPicture == nil else {
            return
        }
        pictureInPicture = PictureInPicture(playerLayer: layer)
        // TODO: Inform the view that pip is now possible.
        // TODO: Inform the view of updates to pip state.
    }
}

extension MovieSession {
    enum State {
        case idle
        case loading
        case loaded(player: AVPlayer)
        case failed
    }
}
