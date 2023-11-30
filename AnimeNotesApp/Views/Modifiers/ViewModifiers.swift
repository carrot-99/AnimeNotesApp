// ViewModifiers.swift

import SwiftUI

struct FlatTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
            )
    }
}

extension View {
    func flatTextFieldStyle() -> some View {
        self.modifier(FlatTextField())
    }
}
