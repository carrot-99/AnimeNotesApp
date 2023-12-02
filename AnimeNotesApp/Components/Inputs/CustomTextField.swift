//  CustomTextField.swift

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}
