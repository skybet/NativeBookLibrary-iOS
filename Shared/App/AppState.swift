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
    @Published var books: [Book] = []

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

        Firestore.firestore().collection(Constants.bookCollection)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.stage = .signIn
                    print("⛔️ Could not find books snapshot: \(error)"); return
                }

                do {
                    self.books = try snapshot?.documents.compactMap({ snapshot in
                        try snapshot.data(as: Book.self)
                    }) ?? []
                } catch {
                    print("⛔️ \(error)")
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
        static let bookCollection = "books"
        static let userCollection = "users"
    }
}
