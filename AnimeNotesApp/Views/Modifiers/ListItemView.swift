// ListItemView.swift

import SwiftUI

struct ListItemView: View {
    var title: String
    var iconName: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                
                Text(title)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
