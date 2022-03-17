//
//  ContentView.swift
//  Shared
//
//  Created by Matthew Gallagher on 03/03/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            book(ISBN: "978-1-80323-445-8")
            Divider()
            book(ISBN: "9789811486043")
            Divider()
            book(ISBN: "9781950325467")
            Divider()
            book(ISBN: "978-1-4842-6448-5")

            //ScannerView()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .padding()
        .sheet(item: $viewModel.selectedBook) { book in
            BookView(book: book)
        }
    }

    private func book(ISBN: String) -> some View {
        Text(ISBN)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .onTapGesture {
                Task() {
                    await viewModel.loadBook(ISBN: ISBN)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
