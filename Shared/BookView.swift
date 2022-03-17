//
//  BookView.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

import SwiftUI

struct BookView: View {
    let book: OnlineBook

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                AsyncImage(url: book.thumbnailURL)
                    .frame(width: 128, height: 192)
                    .aspectRatio(contentMode: .fill)

                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(.title)

                    Text(book.subtitle)
                        .font(.subheadline)

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
        }
        .padding()
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(book: OnlineBook.sample)
    }
}
