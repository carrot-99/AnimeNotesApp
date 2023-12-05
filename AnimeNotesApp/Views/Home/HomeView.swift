//  HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(authService: AuthenticationService())
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ForEach(UserAnimeStatus.allCases, id: \.self) { status in
                    NavigationLink(
                        destination: StatusAnimeListView(
                            viewModel: viewModel.getOrCreateStatusViewModel(for: status.rawValue)
                        )
                    ) {
                        StatusCountView(label: status.description, count: viewModel.count(for: status))
                    }
                }
                Spacer()
            }
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshStatusCounts) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .background(colorScheme == .dark ? Color(white: 0.05) : Color(UIColor.systemGroupedBackground))
        }
        .onAppear(perform: viewModel.refreshStatusCounts)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
