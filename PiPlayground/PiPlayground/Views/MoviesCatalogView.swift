//
//  MoviesCatalogView.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 31/01/24.
//

import SwiftUI

struct MoviesCatalogView: View {
    var movies: [Movie] = MovieCatalog.default.movies
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                movieCatalog
                    .navigationDestination(for: Movie.self) { movie in
                        MovieView(movieSession: MovieSession(movie: movie))
                    }
            }
        }
    }
    
    private var header: some View {
        VStack {
            HStack {
                Text("PiPlayground")
                Image(systemName: "video.circle")
            }
            .font(.title)
            
            Divider()
        }
    }
    
    private var movieCatalog: some View {
        ScrollView {
            // TODO: Replace ForEach with a List.
            ForEach(movies) { movie in
                catalogItem(for: movie)
            }
            .padding(.horizontal)
        }
    }
    
    private func catalogItem(for movie: Movie) -> some View {
        NavigationLink(value: movie) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(movie.title)
                        Text(movie.subtitle)
                    }
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
                .padding(.vertical)
                Divider()
            }
        }
    }
}

#Preview {
    MoviesCatalogView()
}
