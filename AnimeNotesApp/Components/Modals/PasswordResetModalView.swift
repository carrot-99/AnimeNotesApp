//  PasswordResetModalView.swift

import SwiftUI

struct PasswordResetModalView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("パスワードリセット")
                    .font(.headline)
                CustomTextField(placeholder: "メールアドレス", text: $email)
                Button("リセットメールを送信") {
                    if Validation.isValidEmail(email) {
                        userSessionViewModel.resetPassword(email: email)
                        isPresented = false
                    } else {
                        alertMessage = "無効なメールアドレスです。"
                        showingAlert = true
                    }
                }
                .primaryButtonStyle()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                Spacer()
            }
            .padding()
            .navigationTitle("パスワードリセット")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
