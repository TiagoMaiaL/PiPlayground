//
//  MovieSession.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import AVFoundation
import AVKit
import Combine

final class MovieSession: ObservableObject {
    let movie: Movie
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
}

extension MovieSession {
    enum State {
        case idle
        case loading
        case loaded(player: AVPlayer)
        case failed
    }
}

extension MovieSession {
    final class PictureInPicture {
        static let isSupportedByCurrentDevice = AVPictureInPictureController.isPictureInPictureSupported()
        
        // TODO: Make this property non-optional.
        private var pipController: AVPictureInPictureController?
        private(set) var state: State
        
        init?(player: AVPlayerLayer) {
            guard Self.isSupportedByCurrentDevice else {
                return nil
            }
            
            // TODO: Create pipController and make it ready.
            // TODO: Mark this initializer as being async.
            state = .inactive
        }
        
        func start() {
            pipController?.startPictureInPicture()
        }
        
        func stop() {
            pipController?.stopPictureInPicture()
        }
        
        // TODO: Listen to the pipController delegate to determine status.
        
        enum State {
            case active
            case inactive
        }
    }
}
