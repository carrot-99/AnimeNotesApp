// AccountInfoView.swift

import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var isEditing = false

    var body: some View {
        List {
            if let user = userSessionViewModel.currentUser {
                Section(header: Text("ユーザー情報").font(.headline)) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        Text("\(user.email ?? "不明")")
                    }
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        Text("\(user.username ?? "未設定")")
                    }
                }
                Section {
                    Button("アカウント情報の編集") {
                        isEditing = true
                    }
                    .background(
                        NavigationLink(
                            destination: EditAccountInfoView(),
                            isActive: $isEditing,
                            label: { EmptyView() }
                        )
                        .hidden()
                    )
                }
            } else {
                Text("ユーザー情報が取得できませんでした。")
            }
        }
        .navigationBarTitle("アカウント情報")
        .onAppear {
            userSessionViewModel.fetchCurrentUser()
        }
    }
}
