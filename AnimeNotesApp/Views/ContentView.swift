//  ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @AppStorage("isTermsAgreed") private var isTermsAgreed = false

    var body: some View {
        Group {
            if !isTermsAgreed {
                TermsAgreementView(isTermsAgreed: $isTermsAgreed)
            } else if session.isAuthenticated || session.isGuestMode {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: session.isAuthenticated)
        .animation(.easeInOut, value: session.isGuestMode)
    }
}
