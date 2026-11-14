// AccountInfoView.swift

import SwiftUI

struct AccountInfoView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @State private var message: String?

    var body: some View {
        List {
            if let user = session.currentUser {
                Section("ユーザー情報") {
                    NavigationLink {
                        EditAccountInfoView()
                    } label: {
                        InfoRow(title: "ユーザー名", value: user.username ?? "未設定", systemImage: "person")
                    }
                    InfoRow(title: "メールアドレス", value: user.email ?? "不明", systemImage: "envelope")
                }

                Section {
                    HStack {
                        Label("メール認証", systemImage: user.isEmailVerified ? "checkmark.seal.fill" : "xmark.seal")
                            .foregroundColor(user.isEmailVerified ? .green : .orange)
                        Spacer()
                        Text(user.isEmailVerified ? "認証済み" : "未認証")
                            .foregroundColor(.secondary)
                    }
                    if !user.isEmailVerified {
                        Button("認証メールを再送") {
                            Task {
                                message = await session.resendVerificationEmail() ?? "認証メールを送信しました。メールをご確認ください。"
                            }
                        }
                    }
                } footer: {
                    if !user.isEmailVerified {
                        Text("メールのリンクを開いたあと、下に引っ張って状態を更新してください。")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("アカウント情報")
        .refreshable { await session.refreshUser() }
        .task { await session.refreshUser() }
        .alert(
            message ?? "",
            isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })
        ) {
            Button("OK", role: .cancel) {}
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}
