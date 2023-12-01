//  SearchResultsView.swift

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var searchVM: SearchViewModel

    var body: some View {
        List(searchVM.searchResults) { anime in
            AnimeListViewComponent(
                anime: anime,
                onStatusIconTap: {
                    searchVM.selectAnimeForStatusUpdate(anime)
                },
                onAnimeTap: {
                    searchVM.selectAnimeForDetail(anime)
                },
                updateStatus: { newStatus in
                    // ここでアニメのステータスを更新するロジックを実装します
                    searchVM.updateWatchingStatus(for: anime.anime_id, newStatus: newStatus)
                }
            )
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
