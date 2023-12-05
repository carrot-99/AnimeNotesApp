// EditAccountInfoView.swift

import SwiftUI

struct EditAccountInfoView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var username: String = ""
    @State private var showingUpdateAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            TextField("ユーザー名を入力", text: $username)
                .modifier(FlatTextField())

            Button("更新") {
                let updatedUser = UserModel(
                    uid: userSessionViewModel.currentUser?.uid ?? "",
                    email: userSessionViewModel.currentUser?.email,
                    username: username
                )
                userSessionViewModel.updateUserInfo(updatedUser: updatedUser)
                showingUpdateAlert = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .alert(isPresented: $showingUpdateAlert) {
                Alert(
                    title: Text("更新完了"),
                    message: Text(userSessionViewModel.updateSuccessMessage ?? "情報が更新されました。"),
                    dismissButton: .default(Text("OK"), action: {
                        if userSessionViewModel.isUpdateSuccessful {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                )
            }
        }
        .onAppear {
            if let user = userSessionViewModel.currentUser {
                username = user.username ?? ""
            }
        }
        .onChange(of: userSessionViewModel.isUpdateSuccessful) { success in
            if success {
                presentationMode.wrappedValue.dismiss()  // ビューを閉じる
            }
        }
        .padding()
    }
}
