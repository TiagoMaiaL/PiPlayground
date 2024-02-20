//
//  MoviesCatalogView.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 31/01/24.
//

import SwiftUI

struct MoviesCatalogView: View {
    @ObservedObject
    var model: Model
    
    @State
    private var pipRestoreContinuation: CheckedContinuation<Bool, Never>?
    
    @State
    private var presentedMovies = [Movie]()
    
    var body: some View {
        NavigationStack(path: $presentedMovies) {
            VStack(spacing: 0) {
                header
                movieCatalog
                    .navigationDestination(for: Movie.self) { movie in
                        MovieView(movieSession: model.session(for: movie, usingRestorer: self))
                            .onAppear {
                                pipRestoreContinuation?.resume(returning: true)
                                pipRestoreContinuation = nil
                            }
                    }
                    .onAppear {
                        if !model.hasActiveMovieSession {
                            model.clearCurrentMovieSession()
                        }
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
        List(model.movieCatalog.movies) { movie in
            catalogItem(for: movie)
        }
        .padding(.horizontal)
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
                }
                .padding(.vertical)
            }
        }
    }
}

extension MoviesCatalogView: PictureInPicturePlaybackRestorer {
    func restore() async -> Bool {
        return await withCheckedContinuation { continuation in
            guard model.hasActiveMovieSession, let activeSession = model.currentMovieSession else {
                continuation.resume(returning: false)
                return
            }
            pipRestoreContinuation = continuation
            presentedMovies = [activeSession.movie]
        }
    }
}

#Preview {
    MoviesCatalogView(model: Model())
}
