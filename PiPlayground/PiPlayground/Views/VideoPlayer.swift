//
//  VideoPlayer.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 14/02/24.
//

import SwiftUI
import AVFoundation

struct VideoPlayer: View {
    weak var player: AVPlayer!
    private var onLayerAppearanceAction: ((AVPlayerLayer) -> ())?
    
    init(player: AVPlayer, onLayerApperance onLayerAppearanceAction: ((AVPlayerLayer) -> ())? = nil) {
        self.player = player
        self.onLayerAppearanceAction = onLayerAppearanceAction
    }
    
    var body: some View {
        VisualLayer(for: player, onAppear: onLayerAppearanceAction)
    }
    
    func onLayerAppearance(perform action: @escaping (AVPlayerLayer) -> ()) -> Self {
        VideoPlayer(player: self.player, onLayerApperance: action)
    }
}

extension VideoPlayer {
    private struct VisualLayer: UIViewRepresentable {
        private weak var player: AVPlayer!
        private var onAppear: ((AVPlayerLayer) -> ())?
        
        init(for player: AVPlayer, onAppear: ((AVPlayerLayer) -> ())?) {
            self.player = player
            self.onAppear = onAppear
        }
        
        func makeUIView(context: Context) -> UIView {
            _VisualLayer(for: player, onAppear: self.onAppear)
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    
    private final class _VisualLayer: UIView {
        // https://developer.apple.com/documentation/avfoundation/avplayerlayer
        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }
        
        private var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }
        
        private var player: AVPlayer {
            get { playerLayer.player! }
            set { playerLayer.player = newValue }
        }
        
        private var onAppear: ((AVPlayerLayer) -> ())?
        
        init(for player: AVPlayer, onAppear: ((AVPlayerLayer) -> ())?) {
            super.init(frame: .zero)
            self.player = player
            self.onAppear = onAppear
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            onAppear?(playerLayer)
        }
    }
}

#Preview {
    VideoPlayer(
        player: AVPlayer(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        )
    )
}
