// ButtonStyles.swift

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .blue
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(configuration.isPressed ? color.opacity(0.8) : color)
            .cornerRadius(10)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension Button {
    func primaryButtonStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
}
