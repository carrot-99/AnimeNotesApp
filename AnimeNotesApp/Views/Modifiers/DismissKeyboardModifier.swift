//  DismissKeyboardModifier.swift

import SwiftUI

extension View {
    /// 余白をタップしたらキーボードを閉じる（ボタン等のタップは妨げない）
    func dismissKeyboardOnTap() -> some View {
        background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
}
