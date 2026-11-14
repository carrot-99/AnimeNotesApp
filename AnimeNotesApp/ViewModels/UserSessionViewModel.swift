//  UserSessionViewModel.swift

import Foundation

/// ログイン状態とアカウント操作を管理する。アプリ全体で 1 つだけ生成し、EnvironmentObject で共有する。
@MainActor
final class UserSessionViewModel: ObservableObject {
    private static let guestModeKey = "isGuestMode"

    @Published private(set) var currentUser: UserModel?
    @Published private(set) var isProcessing = false
    /// アカウントなしで利用中かどうか（次回起動時も維持する）
    @Published private(set) var isGuestMode: Bool {
        didSet { UserDefaults.standard.set(isGuestMode, forKey: Self.guestModeKey) }
    }

    private let authService: AuthenticationServiceProtocol
    private var authObservation: AnyObject?

    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        // 起動時にログイン画面が一瞬表示されないよう、復元済みのユーザーで初期化する
        self.currentUser = authService.currentUser
        self.isGuestMode = UserDefaults.standard.bool(forKey: Self.guestModeKey)

        authObservation = authService.observeAuthState { [weak self] user in
            Task { @MainActor in self?.handleAuthStateChange(user) }
        }
    }

    var isAuthenticated: Bool { currentUser != nil }
    var userId: String? { currentUser?.uid }
    var isEmailVerified: Bool { currentUser?.isEmailVerified ?? false }

    private func handleAuthStateChange(_ user: UserModel?) {
        guard let user else {
            currentUser = nil
            return
        }
        isGuestMode = false
        // ユーザー名は Auth の情報に含まれないため引き継ぐ
        let username = currentUser?.uid == user.uid ? currentUser?.username : nil
        currentUser = UserModel(uid: user.uid, email: user.email, username: username, isEmailVerified: user.isEmailVerified)
        Task { await refreshUser() }
    }

    // MARK: - ゲストモード

    func enterGuestMode() {
        isGuestMode = true
    }

    /// ログイン画面に戻る
    func exitGuestMode() {
        isGuestMode = false
    }

    // MARK: - 認証

    /// 成功時は nil、失敗時はエラーメッセージを返す
    func signIn(email: String, password: String) async -> String? {
        await perform { try await self.authService.signIn(email: email, password: password) }
    }

    func createAccount(email: String, password: String) async -> String? {
        await perform { try await self.authService.createAccount(email: email, password: password) }
    }

    func sendPasswordReset(email: String) async -> String? {
        await perform { try await self.authService.sendPasswordReset(email: email) }
    }

    func signOut() -> String? {
        do {
            try authService.signOut()
            currentUser = nil
            return nil
        } catch {
            return error.userMessage
        }
    }

    // MARK: - アカウント情報

    func refreshUser() async {
        guard let user = try? await authService.reloadCurrentUser() else { return }
        let username = try? await authService.fetchUsername(userId: user.uid)
        currentUser = UserModel(
            uid: user.uid,
            email: user.email,
            username: username ?? currentUser?.username,
            isEmailVerified: user.isEmailVerified
        )
    }

    func resendVerificationEmail() async -> String? {
        await perform { try await self.authService.sendEmailVerification() }
    }

    func updateUsername(_ username: String) async -> String? {
        guard let userId else { return AppError.notSignedIn.errorDescription }
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let error = await perform { try await self.authService.updateUsername(trimmed, userId: userId) }
        if error == nil {
            currentUser?.username = trimmed
        }
        return error
    }

    func deleteAccount(password: String) async -> String? {
        let error = await perform { try await self.authService.deleteAccount(password: password) }
        if error == nil {
            currentUser = nil
            isGuestMode = false
        }
        return error
    }

    private func perform(_ operation: @escaping () async throws -> Void) async -> String? {
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await operation()
            return nil
        } catch {
            return error.userMessage
        }
    }
}
