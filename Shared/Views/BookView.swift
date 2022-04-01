//
//  BookView.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

import SwiftUI

struct BookView: View {
    let book: OnlineBook
    let state: BookViewState

    @StateObject private var viewModel = BookViewModel()

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                AsyncImage(url: book.thumbnailURL)
                    .frame(width: 128, height: 192)
                    .aspectRatio(contentMode: .fill)

                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(.title)

                    if let subtitle = book.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                    }

                    if let ISBN = book.ISBN {
                        Text("ISBN: \(ISBN)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(.accentColor)
            }

            ScrollView {
                Text(book.description)
                    .foregroundColor(.accentColor)
            }

            Spacer()

            Button(action: {
                switch state {
                case .adding:
                    viewModel.addBook(book)
                case .checkingIn, .checkoutOut:
                    break
                }

                presentationMode.wrappedValue.dismiss()
            }, label: {
                Label(state.buttonText, systemImage: "checkmark")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.barcodeFinderFound)
                    )
            })
        }
        .padding()
    }

    enum BookViewState {
        case adding
        case checkingIn
        case checkoutOut

        var buttonText: String {
            switch self {
            case .adding:
                return "Add to Library"
            case .checkingIn:
                return "Check In"
            case .checkoutOut:
                return "Check Out"
            }
        }
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(book: OnlineBook.sample, state: .adding)
    }
}
