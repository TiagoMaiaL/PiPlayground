//
//  PictureInPicture.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 16/02/24.
//

import AVKit
import AVFoundation
import Combine

@Observable final class PictureInPicture: NSObject {
    static let isSupportedByCurrentDevice = AVPictureInPictureController.isPictureInPictureSupported()
    
    private(set) var state: State
    
    var playbackRestorer: PictureInPicturePlaybackRestorer?
    
    private var pipController: AVPictureInPictureController?
    
    var canBeStarted: Bool {
        state == .inactive
    }
    
    init(playerLayer: AVPlayerLayer) async {
        guard Self.isSupportedByCurrentDevice,
              let _pipController = AVPictureInPictureController(playerLayer: playerLayer) else {
            debugPrint("Pip is unsupported.")
            state = .unsupported
            super.init()
            return
        }
        
        pipController = _pipController
        
        if await _pipController.isPipPossible {
            state = .inactive
            _pipController.canStartPictureInPictureAutomaticallyFromInline = true
        } else {
            debugPrint("Pip is unsupported.")
            state = .unsupported
        }
        
        super.init()
        
        pipController?.delegate = self
    }
    
    func start() {
        guard state != .unsupported else {
            return
        }
        debugPrint("Pip starting.")
        pipController?.startPictureInPicture()
    }
    
    func stop() {
        guard state != .unsupported else {
            return
        }
        debugPrint("Pip stopping.")
        pipController?.stopPictureInPicture()
    }
    
    enum State {
        case unsupported
        case active
        case inactive
    }
}

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("Pip is active.")
        state = .active
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("Pip is inactive.")
        state = .inactive
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        debugPrint("Pip error: \(error)")
        state = .unsupported
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController) async -> Bool {
        guard let playbackRestorer else { return false }
        return await playbackRestorer.restore()
    }
}

protocol PictureInPicturePlaybackRestorer {
    func restore() async -> Bool
}

extension AVPictureInPictureController {
    var isPipPossible: Bool {
        get async {
            var wasContinuationResumed = false
            return await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable!
                cancellable = publisher(for: \.isPictureInPicturePossible)
                    .filter { $0 == false }
                    .receive(on: RunLoop.main)
                    .timeout(.seconds(1), scheduler: RunLoop.main)
                    .removeDuplicates()
                    .sink(receiveCompletion: { _ in
                        if !wasContinuationResumed {
                            continuation.resume(returning: false)
                            wasContinuationResumed = true
                        }
                        cancellable?.cancel()
                    }, receiveValue: { _ in
                        guard wasContinuationResumed == false else { return }
                        wasContinuationResumed = true
                        
                        debugPrint("Pip is possible.")
                        continuation.resume(returning: true)
                    })
            }
        }
    }
}
