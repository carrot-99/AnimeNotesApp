// AuthenticationServiceProtocol.swift

import Foundation

protocol AuthenticationServiceProtocol {
    /// 現在ログイン中のユーザー（ユーザー名は含まない）
    var currentUser: UserModel? { get }

    /// ログイン状態の変化を監視する。戻り値を破棄すると監視を終了する。
    func observeAuthState(_ handler: @escaping (UserModel?) -> Void) -> AnyObject

    func createAccount(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func sendPasswordReset(email: String) async throws
    func sendEmailVerification() async throws
    /// サーバーから最新のユーザー情報（メール認証状態など）を取得する
    func reloadCurrentUser() async throws -> UserModel?

    func fetchUsername(userId: String) async throws -> String?
    func updateUsername(_ username: String, userId: String) async throws

    /// 再認証したうえで、視聴履歴などのデータとアカウントを削除する
    func deleteAccount(password: String) async throws
}
