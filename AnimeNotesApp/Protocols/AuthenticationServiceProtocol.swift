// AuthenticationServiceProtocol.swift

import Combine
import FirebaseAuth

protocol AuthenticationServiceProtocol {
    func createAccount(email: String, password: String) -> AnyPublisher<User, Error>
    func signIn(email: String, password: String) -> AnyPublisher<User, Error>
    func signOut() -> AnyPublisher<Void, Error>
    var currentUserId: String { get }
}
