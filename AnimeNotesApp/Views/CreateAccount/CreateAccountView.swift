// CreateAccountView.swift

import SwiftUI

struct CreateAccountView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(placeholder: "メールアドレス(user@example.com)", text: $email)
            CustomTextField(placeholder: "パスワード(英字と数字を含む8文字以上)", text: $password, isSecure: true)
            CustomTextField(placeholder: "パスワード確認", text: $confirmPassword, isSecure: true)

            if let errorMessage = userSessionViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if userSessionViewModel.isLoading {
                ProgressView()
            } else {
                Button("アカウント作成") {
                    if validateInputs() {
                        userSessionViewModel.createAccount(email: email, password: password)
                    } else {
                        showingAlert = true
                    }
                }
                .primaryButtonStyle()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .padding()
        .dismissKeyboardOnTap()
    }

    private func validateInputs() -> Bool {
        // メールアドレス形式のチェック
        if !isValidEmail(email) {
            alertMessage = "無効なメールアドレスです。"
            return false
        }

        // パスワードの文字数チェック
        if password.count < 8 {
            alertMessage = "パスワードは8文字以上である必要があります。"
            return false
        }

        // 英字と数字が含まれているかチェック
        let containsLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let containsDigit = password.range(of: "\\d", options: .regularExpression) != nil

        if !containsLetter || !containsDigit {
            alertMessage = "パスワードは英字と数字を含む必要があります。"
            return false
        }

        // パスワードと確認用パスワードが一致するかチェック
        if password != confirmPassword {
            alertMessage = "パスワードが一致しません。"
            return false
        }

        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
