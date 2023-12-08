//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @StateObject var seasonListViewModel = SeasonListViewModel()
    
    var body: some View {
        TabView {
            SeasonListView(seasonListVM: seasonListViewModel)
                .environmentObject(userSessionViewModel)
                .tabItem {
                    Label("リスト", systemImage: "list.dash")
                }
            
            SearchView()
                .environmentObject(userSessionViewModel)
                .tabItem {
                    Label("検索", systemImage: "magnifyingglass")
                }
            
            HomeView()
                .environmentObject(userSessionViewModel)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
            
            SettingsView()
                .environmentObject(userSessionViewModel)
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
        }
        .onAppear {
            seasonListViewModel.resetNavigationState()
        }
    }
}
