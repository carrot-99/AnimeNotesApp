//  UserSessionViewModel.swift

import Combine
import Foundation
import FirebaseFirestore

class UserSessionViewModel: ObservableObject {
    @Published var isUserAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: UserModel?
    @Published var updateSuccessMessage: String?
    private var cancellables: Set<AnyCancellable> = []
    private let authService: AuthenticationServiceProtocol

    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }
    
    func createAccount(email: String, password: String) {
        isLoading = true
        authService.createAccount(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] user in
                self?.isUserAuthenticated = true
                print("Account created for user ID: \(user.uid)")
            })
            .store(in: &cancellables)
    }

    func signIn(email: String, password: String) {
        isLoading = true
        authService.signIn(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] user in
                self?.isUserAuthenticated = true
                print("Logged in user ID: \(user.uid)")
            })
            .store(in: &cancellables)
    }

    func signOut() {
        authService.signOut()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] _ in
                self?.isUserAuthenticated = false
            })
            .store(in: &cancellables)
    }
    
    func fetchCurrentUser() {
        guard let firebaseUser = authService.currentUser else { return }
        let user = UserModel(uid: firebaseUser.uid, email: firebaseUser.email)
        currentUser = user

        fetchAdditionalUserInfo(uid: firebaseUser.uid)
    }
        
    private func fetchAdditionalUserInfo(uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let username = data?["username"] as? String
                let age = data?["age"] as? Int
                self?.currentUser?.username = username
                self?.currentUser?.age = age
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateUserInfo(updatedUser: UserModel) {
        var userData: [String: Any] = ["email": updatedUser.email ?? ""]
        if let username = updatedUser.username {
            userData["username"] = username
        }
        if let age = updatedUser.age {
            userData["age"] = age
        }

        authService.updateUserInfo(userId: updatedUser.uid, userData: userData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("Error updating document: \(error)")
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        self?.updateSuccessMessage = "アカウント情報が更新されました。"
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
