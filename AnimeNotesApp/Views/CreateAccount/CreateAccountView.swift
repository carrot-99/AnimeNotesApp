//  CreateAccountView.swift

import SwiftUI

struct CreateAccountView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    
    var body: some View {
        VStack {
            CustomTextField(placeholder: "Email", text: $email)
            CustomTextField(placeholder: "Password", text: $password, isSecure: true)
            
            if let errorMessage = userSessionViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if userSessionViewModel.isLoading {
                ProgressView()
            } else {
                Button("Create Account") {
                    userSessionViewModel.createAccount(email: email, password: password)
                }
            }
        }
        .padding()
        .dismissKeyboardOnTap()
    }
}
