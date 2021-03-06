//
//  ContentViewModel.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

import Foundation

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var selectedBook: OnlineBook?

    var scannedValue: String? {
        didSet {
            guard let scannedValue = scannedValue else { return }
            
            Task() {
                await loadBook(ISBN: scannedValue)
            }
        }
    }

    private static let baseURL = "https://www.googleapis.com/books/v1"

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
