// ListItemView.swift

import SwiftUI

struct ListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var iconName: String?

    var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.25) : Color.gray.opacity(0.5)
    }

    var body: some View {
        HStack(spacing: 16) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .foregroundColor(colorScheme == .dark ? .white : .blue)
                    .imageScale(.large)
            }

            Text(title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
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
        .padding(.vertical, 4)
    }
}
