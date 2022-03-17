//
//  ContentViewModel.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var selectedBook: OnlineBook?

    private static let baseURL = "https://www.googleapis.com/books/v1"
    private static let bookISBN = "978-1-80323-445-8"

    func loadBook(ISBN: String) async {
        guard let url = URL(string: "\(Self.baseURL)/volumes?q=isbn:\(ISBN)") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidServerResponse
            }

            let books = try JSONDecoder().decode(OnlineBooks.self, from: data).books
            selectedBook = books.first
        } catch {
            print("⛔️", String(describing: error), url)
        }
    }
}

enum APIError: Error {
    case invalidServerResponse
}
