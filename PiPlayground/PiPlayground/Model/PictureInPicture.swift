//
//  PictureInPicture.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 16/02/24.
//

import AVKit
import AVFoundation
import Combine

final class PictureInPicture: NSObject {
    static let isSupportedByCurrentDevice = AVPictureInPictureController.isPictureInPictureSupported()
    
    private(set) var state: State
    private let pipController: AVPictureInPictureController?
    
    init(playerLayer: AVPlayerLayer) async {
        guard Self.isSupportedByCurrentDevice,
              let _pipController = AVPictureInPictureController(playerLayer: playerLayer) else {
            debugPrint("Pip is unsupported.")
            state = .unsupported
            pipController = nil
            super.init()
            return
        }
        
        pipController = _pipController
        
        if await _pipController.isPipPossible {
            state = .inactive
        } else {
            debugPrint("Pip is unsupported.")
            state = .unsupported
        }
        
        super.init()
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
    
    // TODO: Implement PiP restoration.
}

extension AVPictureInPictureController {
    var isPipPossible: Bool {
        get async {
            return await withCheckedContinuation { continuation in
                var isPipPossibleCancellable: AnyCancellable?
                isPipPossibleCancellable = publisher(for: \.isPictureInPicturePossible)
                    .filter { $0 == true }
                    .timeout(1, scheduler: RunLoop.main)
                    .sink(receiveCompletion: { [weak isPipPossibleCancellable] completion in
                        switch completion {
                        case .failure:
                            continuation.resume(returning: false)
                        default: break
                        }
                        
                        isPipPossibleCancellable?.cancel()
                    }, receiveValue: { _ in
                        debugPrint("Pip is possible.")
                        continuation.resume(returning: true)
                    })
            }
        }
    }
}
