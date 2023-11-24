// AnimeListView.swift

import SwiftUI
import FirebaseAuth
import Combine

struct AnimeListView: View {
    @ObservedObject var animeListVM: AnimeListViewModel
    @State private var showingStatusSelection = false
    @State private var selectedAnimeId: Int = 0
    @State private var selectedStatus: Int = 0
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    init(animeListVM: AnimeListViewModel) {
        _animeListVM = ObservedObject(wrappedValue: animeListVM)
    }
    
    var body: some View {
        VStack {
            if animeListVM.isLoading {
                ProgressView("Loading...")
            } else if animeListVM.animes.isEmpty {
                Text("\(animeListVM.season)のアニメは見つかりませんでした。")
                    .foregroundColor(.secondary)
            } else {
                List(animeListVM.animes) { anime in
                    HStack {
                        Image(systemName: iconForStatus(anime.status))
                            .onTapGesture {
                                self.selectedAnimeId = anime.anime_id
                                self.selectedStatus = anime.status
                                self.showingStatusSelection = true
                            }
                        NavigationLink(
                            destination: animeListVM.isAnimeSelected && animeListVM.selectedAnime?.anime_id == anime.anime_id ? AnimeDetailView(anime: anime, detailViewModel: AnimeDetailViewModel(anime: anime, episodeDataService: EpisodeDataService())) : nil,
                            isActive: .constant(animeListVM.isAnimeSelected && animeListVM.selectedAnime?.anime_id == anime.anime_id)
                        ) {
                            Text(anime.title)
                                .onTapGesture {
                                    animeListVM.selectedAnime = anime
                                    animeListVM.isAnimeSelected = true
                                }
                        }
                    }
                }
                .sheet(isPresented: $showingStatusSelection) {
                    StatusSelectionModalView(
                        selectedStatus: $selectedStatus,
                        isPresented: $showingStatusSelection,
                        updateStatus:  { newStatus in
                            let animeDataService = AnimeDataService()
                            animeDataService.updateWatchingStatus(
                                animeId: selectedAnimeId,
                                newStatus: newStatus,
                                userId: animeListVM.userId)
                                .sink(
                                    receiveCompletion: { completion in
                                        if case let .failure(error) = completion {
                                            print("Error updating status: \(error.localizedDescription)")
                                        }
                                        self.showingStatusSelection = false
                                    },
                                    receiveValue: { _ in
                                        if let index = self.animeListVM.animes.firstIndex(where: { $0.anime_id == selectedAnimeId }) {
                                            self.animeListVM.animes[index].status = newStatus
                                        }
                                    }
                                )
                                .store(in: &cancellables)
                        }
                    )
                }
            }
        }
        .navigationTitle("\(animeListVM.season)アニメ")
        .alert(isPresented: $animeListVM.showingError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

