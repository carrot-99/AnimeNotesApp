//  AnimeCollectionList.swift

import SwiftUI

/// 作品一覧の共通表示（読み込み中・空・一覧）
struct AnimeCollectionList<EmptyContent: View>: View {
    @EnvironmentObject private var session: UserSessionViewModel
    let animes: [UserAnime]
    let isLoading: Bool
    let onStatusChange: (UserAnime, WatchStatus) -> Void
    let onAnimeUpdate: (UserAnime) -> Void
    @ViewBuilder let emptyContent: () -> EmptyContent

    var body: some View {
        List {
            if !session.isAuthenticated {
                Section {
                    GuestPromptRow()
                }
            }

            if !animes.isEmpty {
                Section {
                    ForEach(animes) { anime in
                        AnimeRow(
                            anime: anime,
                            isEditable: session.isAuthenticated,
                            onStatusChange: { onStatusChange(anime, $0) },
                            onAnimeUpdate: onAnimeUpdate
                        )
                    }
                } footer: {
                    Text("\(animes.count)作品")
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if animes.isEmpty {
                if isLoading {
                    ProgressView("読み込み中…")
                } else {
                    emptyContent()
                }
            }
        }
    }
}
