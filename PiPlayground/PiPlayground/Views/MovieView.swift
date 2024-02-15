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
                    .onLayerAppearance(perform: { playerLayer in
                        debugPrint("On AVPlayerLayer appearance: \(playerLayer).")
                        movieSession.setupPictureInPicture(using: playerLayer)
                    })
                    .frame(width: 350, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Spacer()
                
                // TODO: Use the PiP button provided by Apple.
                // TODO: Update button state based on pip state.
                Button("Start picture in picture") {
                    movieSession.pictureInPicture?.start()
                }
                
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
