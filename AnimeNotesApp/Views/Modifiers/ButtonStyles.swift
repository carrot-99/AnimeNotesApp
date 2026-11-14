// ButtonStyles.swift

import SwiftUI

/// 画面の主要な操作に使う横幅いっぱいのボタン
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isEnabled ? color : Color.gray.opacity(0.5))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// 処理中はインジケーターを表示する主要ボタン
struct PrimaryButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isLoading)
    }
}
