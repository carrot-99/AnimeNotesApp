//  LoginView.swift

import SwiftUI
import FirebaseAuth

struct LoginView: View {
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
                Button("Login") {
                    userSessionViewModel.signIn(email: email, password: password)
                }
                .primaryButtonStyle()
            }
            NavigationLink("Create Account", destination: CreateAccountView())
                .foregroundColor(.blue)
        }
        .padding()
        .dismissKeyboardOnTap()
    }
}
