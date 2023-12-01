//  ContentView.swift

import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @AppStorage("isTermsAgreed") var isTermsAgreed = false

    var body: some View {
        if !isTermsAgreed {
            TermsAgreementView(isTermsAgreed: $isTermsAgreed)
        } else if userSessionViewModel.isUserAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
        
        // デバッグ用のリセットボタン
//        Button("同意をリセット") {
//            isTermsAgreed = false
//        }
    }
}
