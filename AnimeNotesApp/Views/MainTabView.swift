//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSessionVM: UserSessionViewModel
    @StateObject var seasonListVM = SeasonListViewModel()
    
    var body: some View {
        TabView {
            SeasonListView(seasonListVM: seasonListVM)
                .tabItem {
                    Label("リスト", systemImage: "list.dash")
                }
            
            SearchView()
                .tabItem {
                    Label("検索", systemImage: "magnifyingglass")
                }
            
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
        }
        .onAppear {
            seasonListVM.resetNavigationState()
        }
    }
}
