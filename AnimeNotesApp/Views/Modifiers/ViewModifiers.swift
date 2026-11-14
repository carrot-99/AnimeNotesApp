// ViewModifiers.swift

import SwiftUI

extension View {
    /// メッセージが設定されたらアラートで表示し、閉じたら nil に戻す
    func errorAlert(_ message: Binding<String?>, title: String = "エラー") -> some View {
        alert(
            title,
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(message.wrappedValue ?? "") }
        )
    }
}

/// フォーム内のエラー・完了メッセージ
struct InlineMessage: View {
    enum Style {
        case error, success

        var color: Color { self == .error ? .red : .green }
        var systemImage: String { self == .error ? "exclamationmark.triangle.fill" : "checkmark.circle.fill" }
    }

    let text: String
    var style: Style = .error

    var body: some View {
        Label(text, systemImage: style.systemImage)
            .font(.footnote)
            .foregroundColor(style.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity)
    }
}
