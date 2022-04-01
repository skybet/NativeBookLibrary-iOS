//
//  SignInWithAppleFirebase.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 25/03/2022.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class SignInWithAppleFirebase {
    //private let onSignedIn: (Bool) -> Void
    private var currentNonce: String?

    /*init(onSignedIn: @escaping (Bool) -> Void) {
        self.onSignedIn = onSignedIn
    }*/

    // MARK: - onReuqest for Sign In button
    func onRequest(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]

        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
    }

    // MARK: - onCompletion for Sign In button
    func onCompletion(result: Result<ASAuthorization, Error>, _ completion: @escaping (String?) -> Void) {
        switch result {
        case .success(let authorization):
            guard let nonce = currentNonce else { fatalError("⛔️ Invalid state: A login callback was received, but no login request was sent.") }
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { completion(nil); print("⛔️ credential is not of type ASAuthorizationAppleIDCredential"); return }
            guard let appleIDToken = appleIDCredential.identityToken else { completion(nil); print("⛔️ Unable to fetch identity token"); return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { completion(nil); print("⛔️ Unable to serialize token string from data: \(appleIDToken.debugDescription)"); return }

            // Save the user to the Keychain
            self.saveUserInKeychain(appleIDCredential.user)

            // Initialize a Firebase credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    completion(nil)
                    print("⛔️", error.localizedDescription); return
                }

                // Mak a request to set user's display name on Firebase (if first time registering)
                if let displayName = appleIDCredential.fullName?.givenName {
                    let changeRequest = authResult?.user.createProfileChangeRequest()

                    changeRequest?.displayName = displayName
                    changeRequest?.commitChanges(completion: { error in
                        if let error = error {
                            print("⛔️", error.localizedDescription); return
                        }

                        print("📝 Updated display name: \(displayName)")
                    })
                }

                if let userID = authResult?.user.uid {
                    print("✅ Successfully authenticated with Firebase")
                    Self.storeUser(userID: userID, emailAddress: appleIDCredential.email, displayName: appleIDCredential.fullName?.givenName, appleIdentifier: idTokenString)
                    completion(userID)
                } else {
                    completion(nil)
                }
            }
        case .failure(let error):
            print("⛔️ Failed to authenticate with Apple:", error)
            completion(nil)
        }
    }

    // MARK: - User checking
    static func checkForExistingUser(_ completion: @escaping (User?) -> Void) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                guard let user = Auth.auth().currentUser else { print("⛔️ Authorised user but not logged into Firebase"); return }
                storeUserLoginTime(userID: user.uid)
                print("✅ Existing user found, \(user.uid) [Email: \(user.email ?? "no-email")] [name: \(user.displayName ?? "Unknown")] - \(KeychainItem.currentUserIdentifier)")
                completion(Auth.auth().currentUser)
            case .revoked:
                print("⛔️ The Apple ID has been revoked for this App")
                signOut()
                completion(nil)
            case .transferred:
                print("⛔️ The Apple ID has been transferred for this App")
                signOut()
                completion(nil)
            case .notFound:
                print("⛔️ No Apple ID found for this App")
                signOut()
                completion(nil)
            @unknown default:
                print("⛔️ This is an unexpected credential state \(credentialState)")
                completion(nil)
            }
        }
    }

    private static func storeUserLoginTime(userID: String) {
        let document = Firestore.firestore().collection(Constants.userCollection).document(userID)
        document.setData(["lastSignIn": Date()], merge: true)
    }

    private static func storeUser(userID: String, emailAddress: String?, displayName: String?, appleIdentifier: String) {
        let document = Firestore.firestore().collection(Constants.userCollection).document(userID)
        let firebaseUser = FirebaseUser(appleIdentifier: appleIdentifier, lastSignIn: Date(), displayName: displayName, emailAddress: emailAddress)

        do {
            try document.setData(from: firebaseUser, merge: true)
        } catch {
            print("⛔️ Could not store user details: \(error)")
        }
    }

    static func signOut() {
        KeychainItem.deleteUserIdentifier()
        try? Auth.auth().signOut()
    }


    // MARK: - Keychain helper method
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("⛔️ Unable to save userIdentifier to keychain.")
        }
    }

    // MARK: - Firebase helper moethods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)

                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }

                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    // MARK: - Constants
    private enum Constants {
        static let userCollection = "users"
    }
}
