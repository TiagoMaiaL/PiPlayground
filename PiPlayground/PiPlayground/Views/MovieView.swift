//
//  MovieView.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 08/02/24.
//

import AVKit
import SwiftUI

struct MovieView: View {
    @ObservedObject
    var movieSession: MovieSession
    
    var body: some View {
        VStack {
            Text(movieSession.movie.title)
                .font(.title)
            Text(movieSession.movie.subtitle)
            
            Spacer()
            
            switch movieSession.state {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                
                Spacer()
                
            case .loaded(let player):
                VideoPlayer(player: player)
                    .frame(width: 350, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Spacer()
                
                // TODO: Use the PiP button provided by Apple.
                Button("Start picture in picture") {
                    // TODO: Start pip for the current session.
                }
                
            case .failed:
                Text("There was an error loading the player.")
                Spacer()
            }
        }
        .task {
            await movieSession.loadVideo()
            movieSession.startPlayback()
        }
    }
}

#Preview {
    MovieView(
        movieSession: MovieSession(
            movie: Movie(
                title: "Movie Title",
                subtitle: "Movie Subtitle",
                url: URL(string: "https://google.com")!
            )
        )
    )
}
