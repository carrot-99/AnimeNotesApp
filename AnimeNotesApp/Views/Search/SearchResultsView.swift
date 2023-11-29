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
                }
            )
        }
    }
}
