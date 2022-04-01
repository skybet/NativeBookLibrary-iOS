//
//  FirebaseUser.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 28/03/2022.
//

import FirebaseAuth

struct FirebaseUser: Codable {
    let appleIdentifier: String
    let lastSignIn: Date
    let displayName: String?
    let emailAddress: String?
}
