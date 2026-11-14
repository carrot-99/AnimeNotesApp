// AnimeRow.swift

import SwiftUI

/// 作品のタイトルと放送情報
struct AnimeInfoLabel: View {
    let anime: UserAnime

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(anime.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            HStack(spacing: 6) {
                Text(anime.seasonText)
                Text("·")
                Text(anime.episodesText)
                if anime.watchStatus != .notWatched {
                    Text("·")
                    Text(anime.watchStatus.label)
                        .foregroundColor(anime.watchStatus.color)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// 作品一覧の 1 行。ログイン中は視聴状況の変更と詳細画面への遷移ができる。
struct AnimeRow: View {
    let anime: UserAnime
    let isEditable: Bool
    let onStatusChange: (WatchStatus) -> Void
    let onAnimeUpdate: (UserAnime) -> Void

    var body: some View {
        if isEditable {
            HStack(spacing: 8) {
                StatusMenu(status: anime.watchStatus, onSelect: onStatusChange)
                NavigationLink {
                    AnimeDetailView(anime: anime, onAnimeChange: onAnimeUpdate)
                } label: {
                    AnimeInfoLabel(anime: anime)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                let isWatched = anime.watchStatus == .watched
                Button {
                    onStatusChange(isWatched ? .notWatched : .watched)
                } label: {
                    Label(isWatched ? "未視聴に戻す" : "視聴済にする",
                          systemImage: isWatched ? "arrow.uturn.backward" : "checkmark")
                }
                .tint(isWatched ? .gray : .green)
            }
            .contextMenu {
                StatusMenuItems(current: anime.watchStatus, onSelect: onStatusChange)
            }
        } else {
            AnimeInfoLabel(anime: anime)
        }
    }
}
