// AnimeListViewComponent.swift

import SwiftUI

struct AnimeListViewComponent: View {
    var anime: UserAnime
    var onStatusIconTap: () -> Void
    var onAnimeTap: () -> Void
    var updateStatus: (Int) -> Void

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
                .foregroundColor(.blue)
                .imageScale(.large)
                .contextMenu { // コンテキストメニューを追加
                    // ステータス選択肢を表示する
                    ForEach(0..<5) { status in
                        Button {
                            updateStatus(status) // ステータス更新関数を呼び出す
                        } label: {
                            Text("Status \(status)")
                        }
                    }
                }
                .onTapGesture(perform: onStatusIconTap)

            Text(anime.title)
                .font(.headline)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .onTapGesture(perform: onAnimeTap)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
