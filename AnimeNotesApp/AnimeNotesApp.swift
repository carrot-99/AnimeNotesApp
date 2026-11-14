// AnimeNotesApp.swift

import SwiftUI

@main
struct AnimeNotesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var session = UserSessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
