//
//  Model.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import Foundation

@Observable final class Model {
    let movieCatalog: MovieCatalog = .default
    
    private(set) var currentMovieSession: MovieSession?
    
    var hasActiveMovieSession: Bool {
        guard let currentMovieSession else {
            return false
        }
        
        switch currentMovieSession.state {
        case .loaded(_, let pictureInPicture):
            return pictureInPicture.state == .active
            
        default:
            return false
        }
    }
    
    func session(for movie: Movie, usingRestorer playbackRestorer: PictureInPicturePlaybackRestorer? = nil) -> MovieSession {
        if let currentMovieSession, currentMovieSession.movie == movie {
            return currentMovieSession
        } else {
            let session = MovieSession(movie: movie)
            session.playbackRestorer = playbackRestorer
            currentMovieSession = session
            return session
        }
    }
    
    func clearCurrentMovieSession() {
        currentMovieSession?.stopPlayback()
        currentMovieSession = nil
    }
}
