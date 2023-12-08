//  SearchResultsView.swift

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var searchVM: SearchViewModel
    @EnvironmentObject private var userSessionViewModel: UserSessionViewModel
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

    var body: some View {
        if userSessionViewModel.isUserAuthenticated {
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
                        searchVM.updateWatchingStatus(for: anime.anime_id, newStatus: newStatus)
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .background(Color(UIColor.systemGroupedBackground))
        } else {
            List(searchVM.searchResultsForUnauthenticatedUser) { anime in
                Text(anime.title.native)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
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
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
