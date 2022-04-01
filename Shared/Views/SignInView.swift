//
//  SignInView.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 28/03/2022.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var delegate = SignInWithAppleFirebase()

    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Spacer()

            SignInWithAppleButton(onRequest: delegate.onRequest, onCompletion: { result in
                delegate.onCompletion(result: result) { userID in
                    appState.subscribe(to: userID)
                }
            })
            .frame(height: 44)
        }
        .padding()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
