//  StatusCountView.swift

import SwiftUI

struct StatusCountView: View {
    @Environment(\.colorScheme) var colorScheme
    let label: String
    let count: Int
    var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.25) : Color.gray.opacity(0.5)
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
            Spacer()
            Text("\(count)")
                .font(.title)
                .foregroundColor(colorScheme == .dark ? .white : .blue)
        }
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.1) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1)
        )
        .shadow(color: colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
