//  ContentView.swift

import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @AppStorage("isTermsAgreed") var isTermsAgreed = false

    var body: some View {
        if !isTermsAgreed {
            TermsAgreementView(isTermsAgreed: $isTermsAgreed)
        } else {
            if userSessionViewModel.isUserAuthenticated || userSessionViewModel.isUsingAppWithoutAccount {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
