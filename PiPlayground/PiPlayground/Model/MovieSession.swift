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

extension MovieSession {
    // TODO: Move this class to its own file.
    final class PictureInPicture: NSObject {
        static let isSupportedByCurrentDevice = AVPictureInPictureController.isPictureInPictureSupported()
        
        private(set) var state: State {
            didSet {
                debugPrint("Pip state is now \(state).")
            }
        }
        private let pipController: AVPictureInPictureController?
        private var isPipPossibleCancellable: AnyCancellable?
        
        init(playerLayer: AVPlayerLayer) {
            // TODO: Mark this initializer as being async.
            // TODO: Consider using a failable initializer here.
            guard Self.isSupportedByCurrentDevice else {
                state = .unsupported
                debugPrint("Pip is unsupported.")
                pipController = nil
                super.init()
                return
            }
            
            state = .inactive
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            
            super.init()
            
            isPipPossibleCancellable = pipController?
                .publisher(for: \.isPictureInPicturePossible)
                // TODO: Implement a timeout in this method.
                .sink { [weak self, weak pipController] isPossible in
                    debugPrint("Pip is possible sink.")
                    guard isPossible else {
                        self?.state = .unsupported
                        return
                    }
                    
                    self?.state = .inactive
                    debugPrint("Pip is possible.")
                    pipController?.delegate = self
                }
        }
        
        func start() {
            guard state != .unsupported else {
                return
            }
            debugPrint("Starting pip.")
            pipController?.startPictureInPicture()
        }
        
        func stop() {
            guard state != .unsupported else {
                return
            }
            debugPrint("Stopping pip.")
            pipController?.stopPictureInPicture()
        }
        
        enum State {
            case unsupported
            case active
            case inactive
        }
    }
}

extension MovieSession.PictureInPicture: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("Pip is active.")
        state = .active
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("Pip is inactive.")
        state = .inactive
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        debugPrint("PiP error: \(error)")
        state = .unsupported
    }
    
    // TODO: Implement PiP restoration.
}
