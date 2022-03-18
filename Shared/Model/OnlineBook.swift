//
//  OnlineBook.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 10/03/2022.
//

import Foundation

struct OnlineBook: Identifiable {
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

    // Used for text date, i.e. Previews
    static var sample: Self {
        Self(id: "123456", eTag: "AG", title: "Swift Book", subtitle: "What a great Swift book", description: "Some things about the book", pageCount: 101, thumbnailURL: nil, authors: ["Matthew Gallagher"], publisher: nil, publishedDate: "2022-03", ISBN: "123456789")
    }
}

// MARK: - Decodable
extension OnlineBook: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(String.self, forKey: .id)
        eTag = try values.decode(String.self, forKey: .eTag)

        let details = try values.nestedContainer(keyedBy: DetailsCodingKeys.self, forKey: .details)
        title = try details.decode(String.self, forKey: .title)
        subtitle = try details.decodeIfPresent(String.self, forKey: .subtitle)
        description = try details.decode(String.self, forKey: .description)

        pageCount = try details.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0

        let imageLinks = try details.decode([String: String].self, forKey: .imageLinks)

        if let thumbnail = imageLinks["thumbnail"] {
            thumbnailURL = URL(string: thumbnail)
        } else {
            thumbnailURL = nil
        }

        authors = try details.decode([String].self, forKey: .authors)
        publisher = try details.decodeIfPresent(String.self, forKey: .publisher)
        publishedDate = try details.decode(String.self, forKey: .publishedDate)

        let industryIdentifiers = try details.decode([IndustryIdentifier].self, forKey: .industryIdentifiers)

        if let identifier = industryIdentifiers.filter({ $0.type == "ISBN_13" }).first {
            ISBN = identifier.identifier
        } else if let identifier = industryIdentifiers.filter({ $0.type == "ISBN_10" }).first {
            ISBN = identifier.identifier
        } else {
            ISBN = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, eTag = "etag", details = "volumeInfo"
    }

    private enum DetailsCodingKeys: String, CodingKey {
        case title, subtitle, description, pageCount, imageLinks, authors, publisher, publishedDate, industryIdentifiers
    }

    private struct IndustryIdentifier: Decodable {
        let type: String
        let identifier: String
    }
}
