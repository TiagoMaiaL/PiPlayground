//
//  MovieCatalog.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import Foundation

struct MovieCatalog {
    let movies: [Movie]
}

extension MovieCatalog {
    static var `default`: Self {
        MovieCatalog(movies: [
            Movie(
                title: "Big Buck Bunny",
                subtitle: "By Blender Foundation",
                url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            ),
            Movie(
                title: "Elephant Dream",
                subtitle: "By Blender Foundation",
                url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
            ),
        ])
    }
}
