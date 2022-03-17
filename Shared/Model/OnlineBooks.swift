//
//  OnlineBooks.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

import Foundation

struct OnlineBooks: Decodable {
    let books: [OnlineBook]

    private enum CodingKeys: String, CodingKey {
        case books = "items"
    }
}
