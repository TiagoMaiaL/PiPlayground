//
//  MovieSession.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import AVFoundation
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
        
        debugPrint("Loading player for asset(\(movie.url))")
        let player = AVPlayer(url: movie.url)
        
        do {
            guard let isPlayable = try await player.currentItem?.asset.load(.isPlayable), isPlayable else {
                debugPrint("Asset is not playable :(")
                state = .failed
                return
            }
            state = .loaded(player: player)
        } catch {
            debugPrint("Asset couldn't be loaded -> \(error)")
            state = .failed
        }
    }
    
    func startPlayback() {
        debugPrint("Starting playback")
        player?.play()
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
