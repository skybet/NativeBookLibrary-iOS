//
//  LibraryView.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 25/03/2022.
//

import SwiftUI
import FirebaseAuth

struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var isAddingBook = false
    @State private var showScanner = false

    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isAddingBook = false
                    showScanner.toggle()
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }

                Spacer()

                profileView(name: appState.user?.displayName) {
                    // Show user profile / sign out
                }
            }

            Spacer()

            library

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showScanner) {
            ScannerView(showScanner: $showScanner, scannedValue: $viewModel.scannedValue)
        }
        .sheet(item: $viewModel.selectedBook) { book in
            BookView(book: book)
        }
    }

    private var library: some View {
        Text("The library is currently awaiting stock")
            .font(.title)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }

    private func profileView(name: String?, _ tapped: (() -> Void)? = nil) -> some View {
        let initial: String

        if name == nil || name!.isEmpty || name == "Unknown" {
            initial = "?"
        } else {
            initial = String(name!.first!).uppercased()
        }

        return Menu {
            Button("Add Book", action: {
                isAddingBook = true
                showScanner.toggle()
            })
        } label: {
            Text(initial)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(.orange)
                )
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
