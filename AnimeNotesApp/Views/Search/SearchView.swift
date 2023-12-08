// SearchView.swift

import SwiftUI
import FirebaseAuth

struct SearchView: View {
    @ObservedObject private var searchVM = SearchViewModel()
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(searchText: $searchText, onSearch: {
                    if userSessionViewModel.isUserAuthenticated {
                        searchVM.searchAnimeByTitleForAuthenticatedUser(title: searchText)
                    } else {
                        searchVM.searchAnimeByTitleForUnauthenticatedUser(title: searchText)
                    }
                })
                
                if searchVM.isLoading {
                    ProgressView("検索中...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    SearchResultsView(searchVM: searchVM)
                }
            }
            .navigationTitle("検索")
            .background(
                NavigationLink(
                    destination: searchVM.isAnimeSelected ? AnimeDetailView(
                        anime: searchVM.selectedAnime!,
                        ViewModel: AnimeDetailViewModel(
                            anime: searchVM.selectedAnime!,
                            episodeDataService: EpisodeDataService()
                        )
                    ) : nil,
                    isActive: $searchVM.isAnimeSelected
                ) {
                    EmptyView()
                }
            )
        }
        .sheet(isPresented: $searchVM.showingStatusSelection) {
            if let selectedAnime = searchVM.selectedAnimeForStatusUpdate {
                StatusSelectionModalView(
                    selectedStatus: $searchVM.selectedStatus,
                    isPresented: $searchVM.showingStatusSelection,
                    updateStatus: { newStatus in
                        searchVM.updateWatchingStatus(for: selectedAnime.anime_id, newStatus: newStatus)
                    }
                )
            } else {
                Text("情報を読み込めませんでした。")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
