//  AuthenticationService.swift

import FirebaseAuth
import FirebaseFirestore

final class AuthenticationService: FirestoreService, AuthenticationServiceProtocol {
    private var auth: Auth { Auth.auth() }
    private var users: CollectionReference { db.collection(FirestoreCollection.users) }

    private struct UserProfile: Codable {
        var email: String?
        var username: String?
    }

    /// Auth の監視ハンドルを保持し、解放時に監視を解除する
    private final class ListenerToken {
        private let handle: AuthStateDidChangeListenerHandle
        init(handle: AuthStateDidChangeListenerHandle) { self.handle = handle }
        deinit { Auth.auth().removeStateDidChangeListener(handle) }
    }

    var currentUser: UserModel? {
        auth.currentUser.map(Self.makeModel)
    }

    func observeAuthState(_ handler: @escaping (UserModel?) -> Void) -> AnyObject {
        let handle = auth.addStateDidChangeListener { _, user in
            handler(user.map(Self.makeModel))
        }
        return ListenerToken(handle: handle)
    }

    func createAccount(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await set(UserProfile(email: email, username: "New User"), at: users.document(result.user.uid))
        // 認証メールの送信失敗はアカウント作成自体の失敗とはしない（後から再送できる）
        try? await result.user.sendEmailVerification()
    }

    func signIn(email: String, password: String) async throws {
        _ = try await auth.signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func sendEmailVerification() async throws {
        guard let user = auth.currentUser else { throw AppError.notSignedIn }
        try await user.sendEmailVerification()
    }

    func reloadCurrentUser() async throws -> UserModel? {
        guard let user = auth.currentUser else { return nil }
        try await user.reload()
        return auth.currentUser.map(Self.makeModel)
    }

    func fetchUsername(userId: String) async throws -> String? {
        let snapshot = try await users.document(userId).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: UserProfile.self).username
    }

    func updateUsername(_ username: String, userId: String) async throws {
        try await users.document(userId).setData(["username": username], merge: true)
    }

    func deleteAccount(password: String) async throws {
        guard let user = auth.currentUser else { throw AppError.notSignedIn }
        guard let email = user.email else { throw AppError.missingEmail }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await deleteUserData(userId: user.uid)
        try await user.delete()
    }

    /// ユーザーに紐づく Firestore のデータ（視聴履歴・エピソード履歴・プロフィール）を削除する
    private func deleteUserData(userId: String) async throws {
        let historySnapshot = try await db.collection(FirestoreCollection.watchingHistory)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()

        var references: [DocumentReference] = []
        for document in historySnapshot.documents {
            let episodes = try await document.reference.collection(FirestoreCollection.episodesHistory).getDocuments()
            references += episodes.documents.map(\.reference)
            references.append(document.reference)
        }
        references.append(users.document(userId))

        try await commitInBatches(references) { batch, reference in
            batch.deleteDocument(reference)
        }
    }

    private static func makeModel(from user: User) -> UserModel {
        UserModel(uid: user.uid, email: user.email, isEmailVerified: user.isEmailVerified)
    }
}
