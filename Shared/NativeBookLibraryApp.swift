//
//  NativeBookLibraryApp.swift
//  Shared
//
//  Created by Matthew Gallagher on 03/03/2022.
//

import SwiftUI
import Firebase

@main
struct NativeBookLibraryApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
