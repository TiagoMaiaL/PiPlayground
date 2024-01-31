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
            HStack {
                Text("PiPlayground")
                Image(systemName: "video.circle")
            }
            .font(.title)
            
            Divider()
            
            ScrollView {
                ForEach(movies, id: \.self) { movie in
                    VStack {
                        HStack {
                            Text(movie)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundStyle(.blue)
                        }
                        Divider()
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    MoviesCatalogView()
}
