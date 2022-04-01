//
//  ContentView.swift
//  Shared
//
//  Created by Matthew Gallagher on 03/03/2022.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.stage {
        case .splash:
            SplashView()
        case .signIn:
            SignInView()
        case .library:
            LibraryView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
