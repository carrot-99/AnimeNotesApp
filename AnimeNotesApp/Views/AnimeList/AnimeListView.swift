// AnimeListView.swift

import SwiftUI
import Combine

struct AnimeListView: View {
    @EnvironmentObject private var userSessionViewModel: UserSessionViewModel
    @ObservedObject var animeListviewModel: AnimeListViewModel
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
            Group {
                if animeListviewModel.isLoading {
                    ProgressView("Loading")
                } else {
                    List(animeListviewModel.animes) { anime in
                        AnimeListViewComponent(
                            anime: anime,
                            onStatusIconTap: {
                                animeListviewModel.selectedAnimeForStatusUpdate = anime
                                animeListviewModel.selectedStatus = anime.status
                                animeListviewModel.showingStatusSelection = true
                            },
                            onAnimeTap: {
                                animeListviewModel.selectAnimeForDetail(anime)
                            },
                            updateStatus: { newStatus in
                                animeListviewModel.updateWatchingStatus(for: anime.anime_id, newStatus: newStatus)
                            }
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .onAppear {
                if animeListviewModel.animes.isEmpty {
                    print("アニメデータがありません。")
                }
            }
            .onAppear {
                animeListviewModel.fetchDataForSeason(isAuthenticated: userSessionViewModel.isUserAuthenticated)
            }
            .navigationBarTitle("\(animeListviewModel.season)アニメ", displayMode: .inline)
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $animeListviewModel.showingStatusSelection) {
                if let selectedAnime = animeListviewModel.selectedAnimeForStatusUpdate {
                    StatusSelectionModalView(
                        selectedStatus: $animeListviewModel.selectedStatus,
                        isPresented: $animeListviewModel.showingStatusSelection,
                        updateStatus: { newStatus in
                            animeListviewModel.updateWatchingStatus(for: selectedAnime.anime_id, newStatus: newStatus)
                        }
                    )
                }
            }
            .background(
                NavigationLink(
                    destination: animeListviewModel.isAnimeSelected ? AnimeDetailView(
                        anime: animeListviewModel.selectedAnime!,
                        ViewModel: AnimeDetailViewModel(
                            anime: animeListviewModel.selectedAnime!,
                            episodeDataService: EpisodeDataService()
                        )
                    ) : nil,
                    isActive: $animeListviewModel.isAnimeSelected,
                    label: { EmptyView() }
                )
            )
        } else {
            List(animeListviewModel.animes) { anime in
                Text(anime.title)
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
        }
    }
}
