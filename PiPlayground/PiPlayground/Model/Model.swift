//
//  Model.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import Foundation

struct Model {
    let movieCatalog: MovieCatalog = .default
    var activeMovieSession: MovieSession?
    
    mutating func createSession(for movie: Movie) -> MovieSession {
        let session = MovieSession(movie: movie)
        activeMovieSession = session
        return session
    }
}
