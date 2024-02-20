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
                
                button(for: pictureInPicture)
                
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
    
    private func button(for pictureInPicture: PictureInPicture) -> some View {
        Button {
            switch pictureInPicture.state {
            case .inactive:
                pictureInPicture.start()
                
            case .active:
                pictureInPicture.stop()
                
            default:
                break
            }
        } label: {
            HStack {
                switch pictureInPicture.state {
                case .unsupported, .inactive:
                    Image(uiImage: AVPictureInPictureController.pictureInPictureButtonStartImage)
                    Text("Start Picture in Picture")
                    
                case .active:
                    Image(uiImage: AVPictureInPictureController.pictureInPictureButtonStopImage)
                    Text("Stop Picture in Picture")
                }
                
            }
        }
        .disabled(pictureInPicture.state == .unsupported)
        .opacity(pictureInPicture.state == .unsupported ? 0.5 : 1)
        .padding(.bottom)
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
