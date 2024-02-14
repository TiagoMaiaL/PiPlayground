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
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    var body: some View {
        VisualLayer(for: player)
    }
}

extension VideoPlayer {
    private struct VisualLayer: UIViewRepresentable {
        private weak var player: AVPlayer!
        
        init(for player: AVPlayer) {
            self.player = player
        }
        
        func makeUIView(context: Context) -> UIView {
            _VisualLayer(for: player)
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
        
        var player: AVPlayer {
            get { playerLayer.player! }
            set { playerLayer.player = newValue }
        }
        
        init(for player: AVPlayer) {
            super.init(frame: .zero)
            self.player = player
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
