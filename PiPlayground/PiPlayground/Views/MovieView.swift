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
                
            case .loaded(let playerLayer, let pictureInPicture):
                VideoPlayer(playerLayer: playerLayer)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Spacer()
                
                // TODO: Use the PiP button provided by Apple.
                Button("Start picture in picture") {
                    pictureInPicture.start()
                }
                .disabled(!pictureInPicture.canBeStarted)
                .opacity(pictureInPicture.canBeStarted ? 1 : 0.5)
                .padding(.bottom)
                
            case .failed:
                Text("There was an error loading the player.")
                Spacer()
            }
        }
        .task {
            switch movieSession.state {
            case .idle:
                await movieSession.loadVideo()
                movieSession.startPlayback()
            default:
                break
            }
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
