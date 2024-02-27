//
//  LoggerUtils.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 26/02/24.
//

import OSLog

extension Logger {
    init(category: Category) {
        self.init(category: category.rawValue)
    }
    
    init(category: String) {
        self.init(subsystem: Constants.appSystem, category: category)
    }
}

extension Logger {
    enum Category: String {
        case movieSession = "Movie Session"
        case pip = "Picture In Picture"
    }
}

extension Logger {
    fileprivate enum Constants {
        static let appSystem = "com.PiPPlayground"
    }
}
