// SeasonListView.swift

import SwiftUI

struct SeasonListView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @StateObject var seasonListVM: SeasonListViewModel

    var body: some View {
        NavigationView {
            List(seasonListVM.seasons, id: \.self) { season in
                Button(action: {
                    seasonListVM.selectSeason(season, isAuthenticated: userSessionViewModel.isUserAuthenticated)
                }) {
                    ListItemView(title: season, iconName: nil)
                }
                .background(
                    NavigationLink(
                        destination: seasonListVM.selectedAnimeListViewModel.map { AnimeListView(animeListviewModel: $0) },
                        isActive: Binding<Bool>(
                            get: { seasonListVM.selectedSeason == season },
                            set: { _ in }
                        ),
                        label: { EmptyView() }
                    )
                    .hidden()
                )
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
