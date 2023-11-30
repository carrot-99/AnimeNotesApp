//  CreateAccountView.swift

import SwiftUI

struct CreateAccountView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            CustomTextField(placeholder: "Email", text: $email)
                .flatTextFieldStyle()
            CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                .flatTextFieldStyle()
            
            if let errorMessage = userSessionViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if userSessionViewModel.isLoading {
                ProgressView()
            } else {
                Button("Create Account") {
                    userSessionViewModel.createAccount(email: email, password: password)
                }
                .primaryButtonStyle()
            }
        }
        .padding()
        .dismissKeyboardOnTap()
    }
}
