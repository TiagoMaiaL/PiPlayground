//
//  VideoPlayer.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 14/02/24.
//

import SwiftUI
import AVKit

struct VideoPlayer: View {
    let playerLayer: AVPlayerLayer
    
    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
    }
    
    var body: some View {
        VisualLayer(avLayer: playerLayer)
    }
}

extension VideoPlayer {
    private struct VisualLayer: UIViewRepresentable {
        let playerLayer: AVPlayerLayer
        
        init(avLayer playerLayer: AVPlayerLayer) {
            self.playerLayer = playerLayer
        }
        
        func makeUIView(context: Context) -> UIView {
            _VisualLayer(avLayer: playerLayer)
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    
    private final class _VisualLayer: UIView {
        private let playerLayer: AVPlayerLayer
        
        init(avLayer playerLayer: AVPlayerLayer) {
            self.playerLayer = playerLayer
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if playerLayer.superlayer == nil {
                layer.addSublayer(playerLayer)
            }
            playerLayer.frame = layer.bounds
        }
    }
}

#Preview {
    let player = AVPlayer(
        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    )
    return VideoPlayer(
        playerLayer: AVPlayerLayer(player: player)
    )
}
