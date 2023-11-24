//  SearchResultsView.swift

import Foundation
import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var searchVM: SearchViewModel

    var body: some View {
        List(searchVM.searchResults) { anime in
            HStack {
                Image(systemName: iconForStatus(anime.status))
                    .onTapGesture {
                        searchVM.selectAnimeForStatusUpdate(anime)
                    }
                Text(anime.title)
                    .onTapGesture {
                        searchVM.selectAnimeForDetail(anime)
                    }
            }
        }
    }
}
