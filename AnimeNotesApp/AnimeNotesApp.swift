// AnimeNotesApp.swift

import SwiftUI

@main
struct AnimeNotesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var userSessionViewModel = UserSessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSessionViewModel)
                .onAppear {
                    NotificationCenter.default.addObserver(
                        forName: .firebaseAuthenticationDidChange,
                        object: nil, queue: .main
                    ) { notification in
                        if let isAuthenticated = notification.object as? Bool {
                            userSessionViewModel.isUserAuthenticated = isAuthenticated
                        }
                    }
                }
        }
    }
}
