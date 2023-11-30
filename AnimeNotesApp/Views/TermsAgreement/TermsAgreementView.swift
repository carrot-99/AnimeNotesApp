//  TermsAgreementView.swift

import SwiftUI

struct TermsAgreementView: View {
    @Binding var isTermsAgreed: Bool
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("利用規約とプライバシーポリシーに同意してください。")
                
                Toggle("同意する", isOn: $isTermsAgreed)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                Button("次へ") {
                    if isTermsAgreed {
                        navigateToLogin = true
                    }
                }
                .disabled(!isTermsAgreed)
                
                NavigationLink(
                    destination: LoginView(),
                    isActive: $navigateToLogin
                ) { EmptyView() }
            }
            .padding()
        }
    }
}
