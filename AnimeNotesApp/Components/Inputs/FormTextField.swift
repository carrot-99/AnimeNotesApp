//  FormTextField.swift

import SwiftUI

/// ログイン・登録画面用の入力欄
struct FormTextField: View {
    enum Kind {
        case email
        case password(isNew: Bool)
    }

    let title: String
    @Binding var text: String
    let kind: Kind
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundColor(.secondary)
                .frame(width: 20)

            field
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)

            if case .password = kind {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(isRevealed ? "パスワードを隠す" : "パスワードを表示"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private var field: some View {
        switch kind {
        case .email:
            TextField(title, text: $text)
                .keyboardType(.emailAddress)
                .textContentType(.username)
        case .password(let isNew):
            Group {
                if isRevealed {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .textContentType(isNew ? .newPassword : .password)
        }
    }

    private var iconName: String {
        switch kind {
        case .email: return "envelope"
        case .password: return "lock"
        }
    }
}
