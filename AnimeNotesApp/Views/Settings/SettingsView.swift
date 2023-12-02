//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if userSessionViewModel.isUserAuthenticated {
                    NavigationLink(destination: AccountInfoView()) {
                        SettingsButtonLabel(title: "アカウント情報", color: Color.blue)
                    }
                    
                    Button(action: { showingLogoutAlert = true }) {
                        SettingsButtonLabel(title: "ログアウト", color: Color.red)
                    }
                    .alert(isPresented: $showingLogoutAlert) {
                        Alert(
                            title: Text("ログアウト"),
                            message: Text("本当にログアウトしますか？"),
                            primaryButton: .destructive(Text("ログアウト"), action: {
                                userSessionViewModel.signOut()
                            }),
                            secondaryButton: .cancel()
                        )
                    }
                } else {
                    NavigationLink(destination: LoginView()) {
                        SettingsButtonLabel(title: "ログイン", color: Color.blue)
                    }
                    
                    NavigationLink(destination: CreateAccountView()) {
                        SettingsButtonLabel(title: "アカウント作成", color: Color.green)
                    }
                }
                
                NavigationLink(destination: TermsView()) {
                    SettingsButtonLabel(title: "利用規約", color: Color.gray)
                }
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    SettingsButtonLabel(title: "プライバシーポリシー", color: Color.gray)
                }
                
                if let errorMessage = userSessionViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("設定")
        }
    }
}
