//
//  NativeBookLibraryApp.swift
//  Shared
//
//  Created by Matthew Gallagher on 03/03/2022.
//

import SwiftUI
import AuthenticationServices
import Firebase

@main
struct NativeBookLibraryApp: App {
    @StateObject private var appState = AppState()
    let revokedNotificationPublisher = NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onReceive(revokedNotificationPublisher) { _ in
                    appState.signOut()
                }
        }
    }
}
