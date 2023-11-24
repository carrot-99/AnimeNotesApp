//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var newAge: String = ""

    var body: some View {
        VStack(spacing: 100) {
            if userSessionViewModel.isUserAuthenticated {
                Button("ログアウト") {
                    userSessionViewModel.signOut()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                
            } else {
                NavigationLink("ログイン", destination: LoginView())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                
                NavigationLink("アカウント作成", destination: CreateAccountView())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }

            if let errorMessage = userSessionViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}
