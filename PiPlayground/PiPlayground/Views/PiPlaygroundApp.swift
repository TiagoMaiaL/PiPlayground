//
//  PiPlaygroundApp.swift
//  PiPlayground
//
//  Created by Tiago Lopes on 31/01/24.
//

import SwiftUI

@main
struct PiPlaygroundApp: App {
    @StateObject
    var model = Model()
    
    var body: some Scene {
        WindowGroup {
            MoviesCatalogView(model: model)
        }
    }
}
