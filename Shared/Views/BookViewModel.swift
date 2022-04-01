//
//  BookViewModel.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 01/04/2022.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookViewModel: ObservableObject {
    func addBook(_ onlineBook: OnlineBook) {
        let userID = Auth.auth().currentUser?.uid ?? "unknown"
        let book = Book(onlineBook: onlineBook, addedBy: userID)
        let collection = Firestore.firestore().collection(Constants.bookCollection)

        do {
            _ = try collection.document(book.id).setData(from: book)
        } catch {
            print("⛔️ Could not store book: \(error)")
        }
    }

    private enum Constants {
        static let bookCollection = "books"
    }
}
