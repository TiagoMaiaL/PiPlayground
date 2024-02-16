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
    private var isPipPossibleCancellable: AnyCancellable?
    
    init(playerLayer: AVPlayerLayer) {
        // TODO: Mark this initializer as being async.
        guard Self.isSupportedByCurrentDevice else {
            debugPrint("Pip is unsupported.")
            state = .unsupported
            pipController = nil
            super.init()
            return
        }
        
        state = .unsupported
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        
        super.init()
        
        isPipPossibleCancellable = pipController?
            .publisher(for: \.isPictureInPicturePossible)
            .filter { $0 == true }
            // TODO: Implement a timeout in this method.
            .sink { [weak self, weak pipController] isPossible in
                debugPrint("Pip is possible.")
                self?.state = .inactive
                pipController?.delegate = self
            }
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
