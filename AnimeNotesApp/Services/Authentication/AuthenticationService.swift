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
    
    var currentUser: UserModel? {
        guard let firebaseUser = Auth.auth().currentUser else {
            return nil
        }
        return UserModel(uid: firebaseUser.uid, email: firebaseUser.email)
    }
    
    init() {
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
                    let userData = UserCreationData(
                        email: email,
                        username: "New User",
                        age: 0
                    )
                    
                    self.setData(userDocumentRef, for: userData)
                        .sink(receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                promise(.failure(error))
                            }
                        }, receiveValue: {
                            promise(.success(user))
                        })
                        .store(in: &self.cancellables)
                }
                
                authResult?.user.sendEmailVerification(completion: { error in
                    if let error = error {
                        print("メール確認送信エラー: \(error.localizedDescription)")
                    }
                })
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
    
    func fetchUserInfo(userId: String) -> AnyPublisher<UserModel, Error> {
        let userDocRef = db.collection("users").document(userId)
        return Future<UserModel, Error> { promise in
            userDocRef.getDocument { documentSnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    guard let data = documentSnapshot.data() else {
                        promise(.failure(NSError(domain: "FirestoreError", code: 1, userInfo: nil)))
                        return
                    }
                    let userModel = UserModel(
                        uid: userId,
                        email: data["email"] as? String,
                        username: data["username"] as? String,
                        age: data["age"] as? Int
                    )
                    promise(.success(userModel))
                } else {
                    promise(.failure(NSError(domain: "FirestoreError", code: 0, userInfo: nil)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUserInfo(userId: String, userData: [String: Any]) -> AnyPublisher<Void, Error> {
        let userDocRef = db.collection("users").document(userId)
        return updateData(userDocRef, data: userData)
    }
    
    struct UserCreationData: Encodable {
        let email: String
        let username: String
        let age: Int
    }
}

extension AuthenticationService {
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.auth.sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
