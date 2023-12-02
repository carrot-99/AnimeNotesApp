//  LoginView.swift

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
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
                        userSessionViewModel.signIn(email: email, password: password)
                    }
                    .primaryButtonStyle()
                }
                Button("パスワードを忘れた場合") {
                    userSessionViewModel.resetPassword(email: email)
                }
                .foregroundColor(.blue)
                NavigationLink("新規アカウント作成", destination: CreateAccountView())
                    .foregroundColor(.blue)
            }
            .padding()
            .dismissKeyboardOnTap()
        }
    }
}
