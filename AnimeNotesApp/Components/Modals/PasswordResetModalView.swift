//  PasswordResetModalView.swift

import SwiftUI

struct PasswordResetModalView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email: String
    @State private var errorMessage: String?
    @State private var isSent = false

    init(initialEmail: String = "") {
        _email = State(initialValue: initialEmail)
    }

    private var trimmedEmail: String { email.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                if isSent {
                    EmptyStateView(
                        systemImage: "envelope.badge",
                        title: "メールを送信しました",
                        message: "\(trimmedEmail) に届いたメールのリンクから、新しいパスワードを設定してください。"
                    ) {
                        Button("閉じる") { dismiss() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                } else {
                    Text("登録済みのメールアドレスを入力してください。パスワード再設定用のリンクをお送りします。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    FormTextField(title: "メールアドレス", text: $email, kind: .email, submitLabel: .send, onSubmit: submit)

                    if let errorMessage {
                        InlineMessage(text: errorMessage)
                    }

                    PrimaryButton(title: "再設定メールを送信", isLoading: session.isProcessing, action: submit)
                        .disabled(!Validation.isValidEmail(trimmedEmail))
                }
                Spacer()
            }
            .padding(24)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("パスワード再設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        guard Validation.isValidEmail(trimmedEmail), !session.isProcessing else { return }
        Task {
            errorMessage = await session.sendPasswordReset(email: trimmedEmail)
            withAnimation {
                isSent = errorMessage == nil
            }
        }
    }
}
