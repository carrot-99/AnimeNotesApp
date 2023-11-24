//  AnimeCell.swift

import SwiftUI

struct AnimeCell: View {
    var anime: Anime
    var isWatched: Bool

    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text(anime.title.native)
                    .font(.headline)
            }
            Spacer()
            Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isWatched ? .green : .gray)
        }
        .padding(.vertical)
    }
}
