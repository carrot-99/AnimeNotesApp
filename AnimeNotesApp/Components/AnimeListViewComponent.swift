// AnimeListViewComponent.swift

import SwiftUI

struct AnimeListViewComponent: View {
    var anime: UserAnime
    var onStatusIconTap: () -> Void
    var onAnimeTap: () -> Void
    var updateStatus: (Int) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255)
        } else {
            return Color.white
        }
    }
    
    var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.25) : Color.gray.opacity(0.5)
    }

    // ステータス選択肢を定義
    let statuses = [
        (0, "未視聴", "eye.slash"),
        (1, "視聴中", "play.circle"),
        (2, "視聴中断", "pause.circle"),
        (3, "視聴済", "checkmark.circle"),
        (4, "視聴予定", "calendar.circle")
    ]

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconForStatus(anime.status))
                .foregroundColor(colorScheme == .dark ? .white : .blue)
                .imageScale(.large)
                .contextMenu {
                    ForEach(0..<5) { status in
                        Button {
                            updateStatus(status)
                        } label: {
                            Text("Status \(status)")
                        }
                    }
                }
                .onTapGesture(perform: onStatusIconTap)

            Text(anime.title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .onTapGesture(perform: onAnimeTap)
        }
        .padding()
        .background(backgroundColor)
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
