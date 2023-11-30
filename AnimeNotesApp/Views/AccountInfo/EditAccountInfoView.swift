// EditAccountInfoView.swift

import SwiftUI

struct EditAccountInfoView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var username: String = ""
    @State private var age: String = ""
    @State private var showingUpdateAlert = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("ユーザー名を入力", text: $username)
                .modifier(FlatTextField())
            
            TextField("年齢を入力", text: $age)
                .modifier(FlatTextField())
                .keyboardType(.numberPad)

            Button("更新") {
                let updatedUser = UserModel(
                    uid: userSessionViewModel.currentUser?.uid ?? "",
                    email: userSessionViewModel.currentUser?.email,
                    username: username,
                    age: Int(age)
                )
                userSessionViewModel.updateUserInfo(updatedUser: updatedUser)
                showingUpdateAlert = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .alert(isPresented: $showingUpdateAlert) {
                Alert(
                    title: Text("更新完了"),
                    message: Text(userSessionViewModel.updateSuccessMessage ?? "情報が更新されました。"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            if let user = userSessionViewModel.currentUser {
                username = user.username ?? ""
                age = user.age.map(String.init) ?? ""
            }
        }
        .padding()
    }
}
