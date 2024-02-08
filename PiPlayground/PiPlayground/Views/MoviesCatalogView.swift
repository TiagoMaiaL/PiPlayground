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
        VStack(spacing: 0) {
            header
            movieCatalog
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
            ForEach(movies) { movie in
                movieCatalogItem(movieName: movie.title)
            }
            .padding(.horizontal)
        }
    }
    
    private func movieCatalogItem(movieName: String) -> some View {
        VStack {
            HStack {
                Text(movieName)
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .padding(.vertical)
            Divider()
        }
    }
}

#Preview {
    MoviesCatalogView()
}
