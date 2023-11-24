//  AuthenticationService.swift

import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthenticationService: FirestoreService, AuthenticationServiceProtocol {
    private var cancellables = Set<AnyCancellable>()

    var auth: Auth {
        return Auth.auth()
    }

    var currentUserId: String {
        return auth.currentUser?.uid ?? ""
    }
    
    init() {
//        print("AuthenticationService 初期化中")
        super.init()
    }
    
    func createAccount(email: String, password: String) -> AnyPublisher<User, Error> {
        Future<User, Error> { [weak self] promise in
            print("アカウント作成を開始")
            guard let self = self else { return }
            self.auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = authResult?.user {
                    let userDocumentRef = self.db.collection("users").document(user.uid)
                    let userData = ["email": email]
                    self.setData(userDocumentRef, for: userData)
                        .sink(receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                promise(.failure(error))
                            }
                        }, receiveValue: {
                            promise(.success(user))
                        })
                        .store(in: &self.cancellables) // Cancellables should be a class property
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        Future<User, Error> { promise in
            self.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                try self.auth.signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
