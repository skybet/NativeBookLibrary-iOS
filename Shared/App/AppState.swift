//
//  State.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 31/03/2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class AppState: ObservableObject {
    @Published var stage: Stage = .splash
    @Published var user: FirebaseUser?

    init() {
        SignInWithAppleFirebase.checkForExistingUser() { [weak self] user in
            guard let self = self else { return }
            self.subscribe(to: user?.uid)
        }
    }

    /// Subscribe to the user details from Firestore.
    /// - Parameter userIDentifier: String matching user identifier within Firestore
    func subscribe(to userIdentifier: String?) {
        guard let userIdentifier = userIdentifier else {
            stage = .signIn
            user = nil
            return
        }

        Firestore.firestore().collection(Constants.userCollection).document(userIdentifier)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.stage = .signIn
                    print("⛔️ Could not find user snapshot: \(error)"); return
                }

                do {
                    self.user = try snapshot?.data(as: FirebaseUser.self)
                    self.stage = .library
                } catch {
                    print("⛔️ \(error)")
                    self.stage = .signIn
                }
            }
    }

    /// Sign the user out of Apple and Firebase.
    func signOut() {
        stage = .signIn
        user = nil
        SignInWithAppleFirebase.signOut()
    }

    // MARK: - Stage
    enum Stage {
        case splash
        case signIn
        case library
    }

    // MARK: - Constants
    private enum Constants {
        static let userCollection = "users"
    }
}
