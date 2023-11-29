//  AnimeListViewComponent.swift

import SwiftUI

struct AnimeListViewComponent: View {
    var anime: UserAnime
    var onStatusIconTap: () -> Void
    var onAnimeTap: () -> Void

    var body: some View {
        HStack {
            Image(systemName: iconForStatus(anime.status))
                .onTapGesture(perform: onStatusIconTap)
            Text(anime.title)
                .onTapGesture(perform: onAnimeTap)
        }
    }
}
