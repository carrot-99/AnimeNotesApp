// SeasonListView.swift

import SwiftUI

struct SeasonListView: View {
    @StateObject var seasonListVM: SeasonListViewModel

    var body: some View {
        NavigationStack {
            List(seasonListVM.seasons, id: \.self) { season in
                ListItemView(title: season, iconName: nil, action: {
                    seasonListVM.selectSeason(season)
                })
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
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
            .navigationDestination(isPresented: $seasonListVM.navigateToAnimeList) {
                seasonListVM.navigateToAnimeDetail()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
