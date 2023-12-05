// SeasonListView.swift

import SwiftUI

struct SeasonListView: View {
    @StateObject var seasonListVM: SeasonListViewModel

    var body: some View {
        NavigationView {
            List(seasonListVM.seasons, id: \.self) { season in
                NavigationLink(
                    destination: seasonListVM.selectedAnimeListViewModel.map { AnimeListView(viewModel: $0) },
                    isActive: Binding<Bool>(
                        get: { seasonListVM.selectedSeason == season },
                        set: { isActive in
                            if isActive {
                                seasonListVM.selectSeason(season)
                            }
                        }
                    )
                ) {
                    ListItemView(title: season, iconName: nil)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onAppear {
                seasonListVM.resetNavigationState()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("クール選択")
            .alert(isPresented: $seasonListVM.hasError) {
                Alert(
                    title: Text("Error"),
                    message: Text(seasonListVM.errorMessage),
                    dismissButton: .default(Text("OK")) {
                        seasonListVM.dismissError()
                    }
                )
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
