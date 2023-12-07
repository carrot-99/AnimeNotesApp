//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingPasswordPrompt = false
    @State private var passwordInput = ""

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
                    
                    if userSessionViewModel.isLoading {
                        ProgressView("処理中...")
                    }
                    
                    Button(action: {
                        self.showingPasswordPrompt = true
                    }) {
                        SettingsButtonLabel(title: "アカウント削除", color: Color.red)
                    }
                    .sheet(isPresented: $showingPasswordPrompt) {
                        VStack(spacing: 20) {
                            Text("アカウントを削除するにはパスワードを入力してください")
                            TextField("パスワード", text: $passwordInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .secureTextFieldStyle()
                            Button("アカウント削除") {
                                userSessionViewModel.attemptToDeleteAccount(password: passwordInput)
                                showingPasswordPrompt = false
                            }
                            .foregroundColor(.red)
                            Button("キャンセル") {
                                showingPasswordPrompt = false
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                        .edgesIgnoringSafeArea(.all)
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
