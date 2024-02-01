//
//  Movie.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 01/02/24.
//

import Foundation

struct Movie: Equatable, Hashable {
    let title: String
    let subtitle: String
    let url: URL
}

extension Movie: Identifiable {
    var id: Int { hashValue }
}
