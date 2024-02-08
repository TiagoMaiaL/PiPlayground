//
//  MovieView.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 08/02/24.
//

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
            
            // TODO: Replace this rectangle with a proper video view.
            Rectangle()
                .background(.gray)
                .aspectRatio(3/2, contentMode: .fit)
                .padding(.horizontal)
            
            Spacer()
            
            // TODO: Use the PiP button provided by Apple.
            Button("Start picture in picture") {
                // TODO: Start pip for the current session.
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
