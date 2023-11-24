//  LoginView.swift

import SwiftUI
import FirebaseAuth

struct LoginView: View {
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
                Button("Login") {
                    userSessionViewModel.signIn(email: email, password: password)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            NavigationLink("Create Account", destination: CreateAccountView())
        }
        .padding()
        .dismissKeyboardOnTap()
        .onAppear {
            print("LoginView が表示された")
            // Firebase サービスへのアクセスをここで行う場合、注意が必要
        }
    }
}
