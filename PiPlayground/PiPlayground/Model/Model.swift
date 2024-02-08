//
//  Model.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import Foundation

final class Model: ObservableObject {
    let movieCatalog: MovieCatalog = .default
    private(set) var activeMovieSession: MovieSession?
    
    func createSession(for movie: Movie) -> MovieSession {
        let session = MovieSession(movie: movie)
        activeMovieSession = session
        return session
    }
}
