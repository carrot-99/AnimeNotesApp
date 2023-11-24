//  AppDelegate.swift

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    var authService: AuthenticationService?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        authService = AuthenticationService()
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .firebaseAuthenticationDidChange, object: user != nil)
            }
        }

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

extension Notification.Name {
    static let firebaseAuthenticationDidChange = Notification.Name("firebaseAuthenticationDidChange")
}
