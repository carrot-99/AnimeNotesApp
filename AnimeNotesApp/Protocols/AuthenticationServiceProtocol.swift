// AuthenticationServiceProtocol.swift

import Combine
import FirebaseAuth

protocol AuthenticationServiceProtocol {
    func createAccount(email: String, password: String) -> AnyPublisher<User, Error>
    func signIn(email: String, password: String) -> AnyPublisher<User, Error>
    func signOut() -> AnyPublisher<Void, Error>
    var currentUserId: String { get }
    func updateUserInfo(userId: String, userData: [String: Any]) -> AnyPublisher<Void, Error>
    func fetchUserInfo(userId: String) -> AnyPublisher<UserModel, Error>
    var currentUser: UserModel? { get }
}
