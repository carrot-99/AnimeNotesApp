//  LoginView.swift

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                CustomTextField(placeholder: "メールアドレス", text: $email)
                CustomTextField(placeholder: "パスワード", text: $password, isSecure: true)
                
                if let errorMessage = userSessionViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if userSessionViewModel.isLoading {
                    ProgressView()
                } else {
                    Button("ログイン") {
                        if validateLoginInputs() {
                            userSessionViewModel.signIn(email: email, password: password)
                        } else {
                            showingAlert = true
                        }
                    }
                    .primaryButtonStyle()
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
                Button("パスワードを忘れた場合") {
                    userSessionViewModel.resetPassword(email: email)
                }
                .foregroundColor(.blue)
                NavigationLink("新規アカウント作成", destination: CreateAccountView())
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationTitle("ログイン")
            .dismissKeyboardOnTap()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func validateLoginInputs() -> Bool {
        if !Validation.isValidEmail(email) {
            alertMessage = "無効なメールアドレスです。"
            return false
        }

        if !Validation.isValidPassword(password) {
            alertMessage = "パスワードは8文字以上であり、英字と数字を含む必要があります。"
            return false
        }

        return true
    }
}
