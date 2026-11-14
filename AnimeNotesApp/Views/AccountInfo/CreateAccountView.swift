// CreateAccountView.swift

import SwiftUI

struct CreateAccountView: View {
    private enum Field { case email, password, confirmation }

    @EnvironmentObject private var session: UserSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private var trimmedEmail: String { email.trimmingCharacters(in: .whitespaces) }
    private var passwordsMatch: Bool { !confirmation.isEmpty && password == confirmation }

    private var canSubmit: Bool {
        Validation.isValidEmail(trimmedEmail) && Validation.isValidPassword(password) && passwordsMatch
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    FormTextField(title: "メールアドレス", text: $email, kind: .email) {
                        focusedField = .password
                    }
                    .focused($focusedField, equals: .email)

                    if !email.isEmpty && !Validation.isValidEmail(trimmedEmail) {
                        InlineMessage(text: "メールアドレスの形式が正しくありません")
                    }

                    FormTextField(title: "パスワード", text: $password, kind: .password(isNew: true)) {
                        focusedField = .confirmation
                    }
                    .focused($focusedField, equals: .password)

                    FormTextField(title: "パスワード（確認）", text: $confirmation, kind: .password(isNew: true), submitLabel: .done) {
                        submit()
                    }
                    .focused($focusedField, equals: .confirmation)

                    requirements

                    Label("登録したアドレスに認証メールが届きます。誤ったアドレスで登録すると、パスワードの再設定などができなくなります。", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    if let errorMessage {
                        InlineMessage(text: errorMessage)
                    }

                    PrimaryButton(title: "アカウントを作成", isLoading: session.isProcessing, action: submit)
                        .disabled(!canSubmit)
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .dismissKeyboardOnTap()
            .navigationTitle("アカウント作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private var requirements: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Validation.passwordRequirements(password)) { requirement in
                RequirementRow(label: requirement.label, isSatisfied: requirement.isSatisfied)
            }
            RequirementRow(label: "確認用パスワードが一致", isSatisfied: passwordsMatch)
        }
        .padding(.horizontal, 4)
    }

    private func submit() {
        guard canSubmit, !session.isProcessing else { return }
        focusedField = nil
        Task {
            // 成功するとログイン状態になり、画面が自動的に切り替わる
            errorMessage = await session.createAccount(email: trimmedEmail, password: password)
            if errorMessage == nil {
                dismiss()
            }
        }
    }
}

private struct RequirementRow: View {
    let label: String
    let isSatisfied: Bool

    var body: some View {
        Label(label, systemImage: isSatisfied ? "checkmark.circle.fill" : "circle")
            .font(.footnote)
            .foregroundColor(isSatisfied ? .green : .secondary)
            .animation(.easeInOut(duration: 0.15), value: isSatisfied)
    }
}
