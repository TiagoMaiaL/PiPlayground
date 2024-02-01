//
//  MoviesCatalogView.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 31/01/24.
//

import SwiftUI

struct MoviesCatalogView: View {
    var movies: [String] {
        [
            "Movie 1",
            "Movie 2",
            "Movie 3",
            "Movie 4"
        ]
    }
    
    var body: some View {
        VStack {
            header
            movieCatalog
        }
    }
    
    @ViewBuilder
    private var header: some View {
        HStack {
            Text("PiPlayground")
            Image(systemName: "video.circle")
        }
        .font(.title)
        
        Divider()
    }
    
    private var movieCatalog: some View {
        ScrollView {
            ForEach(movies, id: \.self) { movie in
                movieCatalogItem(movieName: movie)
            }
            .padding()
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
