//
//  MovieSession.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import Combine

final class MovieSession: ObservableObject {
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
}
