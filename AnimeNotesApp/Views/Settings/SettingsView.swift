//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @State private var isConfirmingSignOut = false
    @State private var isShowingDeleteAccount = false
    @State private var errorMessage: String?

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "-"
        let build = info?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationView {
            List {
                accountSection

                Section("このアプリについて") {
                    NavigationLink {
                        TermsView()
                    } label: {
                        Label("利用規約", systemImage: "doc.text")
                    }
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("プライバシーポリシー", systemImage: "hand.raised")
                    }
                    HStack {
                        Label("バージョン", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("設定")
            .confirmationDialog("ログアウトしますか？", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
                Button("ログアウト", role: .destructive) {
                    errorMessage = session.signOut()
                }
            }
            .sheet(isPresented: $isShowingDeleteAccount) {
                DeleteAccountView()
            }
            .errorAlert($errorMessage)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var accountSection: some View {
        if let user = session.currentUser {
            Section("アカウント") {
                NavigationLink {
                    AccountInfoView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.username ?? "ユーザー名未設定")
                                .font(.headline)
                            Text(user.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Button {
                    isConfirmingSignOut = true
                } label: {
                    Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }

            Section {
                Button(role: .destructive) {
                    isShowingDeleteAccount = true
                } label: {
                    Label("アカウントを削除", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } footer: {
                Text("アカウントを削除すると、すべての視聴記録が削除され、元に戻せません。")
            }
        } else {
            Section {
                Button {
                    session.exitGuestMode()
                } label: {
                    Label("ログイン / アカウント作成", systemImage: "person.crop.circle.badge.plus")
                }
            } header: {
                Text("アカウント")
            } footer: {
                Text("現在はアカウントなしで利用中です。アカウントを作成すると視聴状況を記録できます。")
            }
        }
    }
}

/// アカウント削除（パスワードで再認証してから削除する）
private struct DeleteAccountView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isConfirming = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Label("この操作は取り消せません", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.headline)
                    Text("アカウントと、これまでに記録したすべての視聴状況が完全に削除されます。")
                        .font(.subheadline)
                }

                Section {
                    SecureField("パスワード", text: $password)
                        .textContentType(.password)
                } header: {
                    Text("本人確認")
                } footer: {
                    if let errorMessage {
                        Text(errorMessage).foregroundColor(.red)
                    } else {
                        Text("確認のため、現在のパスワードを入力してください。")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        isConfirming = true
                    } label: {
                        HStack {
                            Spacer()
                            if session.isProcessing {
                                ProgressView()
                            } else {
                                Text("アカウントを削除").bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(password.isEmpty || session.isProcessing)
                }
            }
            .navigationTitle("アカウント削除")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .disabled(session.isProcessing)
                }
            }
            .confirmationDialog("本当にアカウントを削除しますか？", isPresented: $isConfirming, titleVisibility: .visible) {
                Button("削除する", role: .destructive) {
                    Task {
                        errorMessage = await session.deleteAccount(password: password)
                        if errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(session.isProcessing)
    }
}
