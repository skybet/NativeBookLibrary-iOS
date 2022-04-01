//
//  Book.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 01/04/2022.
//

import Foundation

struct Book: Identifiable, Codable {
    let id: String
    let eTag: String
    let title: String
    let subtitle: String?
    let description: String
    let pageCount: Int
    let thumbnailURL: URL?
    let authors: [String]
    let publisher: String?
    let publishedDate: String
    let ISBN: String?
    let addedDate: Date
    let addedBy: String
    var checkedOutBy: String?
}

extension Book {
    init(onlineBook: OnlineBook, addedBy: String) {
        self.id = onlineBook.id
        self.eTag = onlineBook.eTag
        self.title = onlineBook.title
        self.subtitle = onlineBook.subtitle
        self.description = onlineBook.description
        self.pageCount = onlineBook.pageCount
        self.thumbnailURL = onlineBook.thumbnailURL
        self.authors = onlineBook.authors
        self.publisher = onlineBook.publisher
        self.publishedDate = onlineBook.publishedDate
        self.ISBN = onlineBook.ISBN
        self.addedDate = Date()
        self.addedBy = addedBy
    }
}
