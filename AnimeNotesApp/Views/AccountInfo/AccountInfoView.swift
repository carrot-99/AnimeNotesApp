// AccountInfoView.swift

import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel

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
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text("\(user.age.map(String.init) ?? "未設定")")
                    }
                }
                Section {
                    NavigationLink(destination: EditAccountInfoView()) {
                        Text("アカウント情報の編集")
                            .foregroundColor(.blue)
                    }
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
