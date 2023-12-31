//  UserSessionViewModel.swift

import Combine
import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserSessionViewModel: ObservableObject {
    @Published var isUserAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: UserModel?
    @Published var updateSuccessMessage: String?
    @Published var isUpdateSuccessful = false
    @Published var isDeletingAccount = false
    @Published var isEmailVerified = false
    @Published var isUsingAppWithoutAccount = false
    @Published var isAccountDeletionSuccessful = false
    private var cancellables: Set<AnyCancellable> = []
    private let authService: AuthenticationServiceProtocol
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                user.reload { error in
                    if let error = error {
                        print("Error reloading user: \(error)")
                    } else {
                        self.currentUser = UserModel(uid: user.uid, email: user.email)
                        self.isEmailVerified = user.isEmailVerified
                        self.isUserAuthenticated = true
                        print("User isEmailVerified status: \(self.isEmailVerified)")  // 状態をログで確認
                    }
                }
            } else {
                self.isUserAuthenticated = false
                self.currentUser = nil
            }
        }
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
                self?.updateSuccessMessage = "アカウントが作成されました。認証メールをご確認ください。"
                self?.isUserAuthenticated = true
                self?.clearErrorMessage()
            })
            .store(in: &cancellables)
    }

    func signIn(email: String, password: String) {
        isLoading = true
        authService.signIn(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.clearErrorMessage()
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] user in
                self?.isUserAuthenticated = true
                self?.clearErrorMessage()
            })
            .store(in: &cancellables)
    }

    func signOut() {
        authService.signOut()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.clearErrorMessage()
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] _ in
                self?.isUserAuthenticated = false
            })
            .store(in: &cancellables)
    }
    
    func updateUserInfo(updatedUser: UserModel) {
        var userData: [String: Any] = ["email": updatedUser.email ?? ""]
        if let username = updatedUser.username {
            userData["username"] = username
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
                        self?.isUpdateSuccessful = true
                    }
                    if case .finished = completion {
                        self?.fetchCurrentUser() // ユーザー情報の更新後に最新情報を取得
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    private func handleError(_ error: Error) {
        let nsError = error as NSError
        if let errCode = AuthErrorCode.Code(rawValue: nsError.code) {
            switch errCode {
            case .networkError:
                errorMessage = "ネットワークエラーが発生しました。接続を確認してください。"
            case .wrongPassword:
                errorMessage = "間違ったパスワードです。"
            case .userNotFound:
                errorMessage = "ユーザーが見つかりません。"
            case .userDisabled:
                errorMessage = "このアカウントは無効です。"
            default:
                errorMessage = "ログインに失敗しました。入力情報を確認してください。"
            }
        } else {
            errorMessage = "エラーが発生しました。もう一度お試しください。"
        }
    }

    func attemptToDeleteAccount(password: String) {
        isDeletingAccount = true
        guard let currentUser = currentUser, let email = currentUser.email else {
            self.errorMessage = "メールアドレスが利用できません。"
            print("エラー: メールアドレスが利用できません。")
            return
        }
        print("再認証を試みるメールアドレス: \(email)")

        authService.reauthenticate(email: email, password: password)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: CustomError.unknown).eraseToAnyPublisher()
                }
                return self.deleteFirestoreData(for: self.authService.currentUserId)
            }
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: CustomError.unknown).eraseToAnyPublisher()
                }
                return self.authService.deleteUser()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.clearErrorMessage()
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "再認証または削除中にエラーが発生しました: \(error.localizedDescription)"
                case .finished:
                    self?.isAccountDeletionSuccessful = true
                }
            }, receiveValue: { [weak self] _ in
                self?.isUserAuthenticated = false
                self?.errorMessage = "アカウントが正常に削除されました。"
                // 追加のクリーンアップ処理があればここで実行
            })
            .store(in: &cancellables)
    }
    
    private func deleteFirestoreData(for userId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }

            // Firestoreのユーザーデータを削除
            let firestore = Firestore.firestore()
            let userDocRef = firestore.collection("users").document(userId)
            userDocRef.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    // Firestoreの視聴履歴データを削除
                    firestore.collection("userWatchingHistory")
                        .whereField("user_id", isEqualTo: userId)
                        .getDocuments { (querySnapshot, err) in
                            if let err = err {
                                promise(.failure(err))
                            } else {
                                let group = DispatchGroup()
                                querySnapshot?.documents.forEach { document in
                                    group.enter()
                                    document.reference.delete { error in
                                        group.leave()
                                        if let error = error {
                                            promise(.failure(error))
                                            return
                                        }
                                    }
                                }
                                
                                // 全てのデータ削除が完了したら成功を返す
                                group.notify(queue: .main) {
                                    promise(.success(()))
                                }
                            }
                        }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension UserSessionViewModel {
    func resetPassword(email: String) {
        authService.resetPassword(email: email)
            .sink(receiveCompletion: { completion in
                // エラーハンドリング
            }, receiveValue: { _ in
                // メール送信成功メッセージなど
            })
            .store(in: &cancellables)
    }
    
    func resendVerificationEmail() {
        guard let firebaseUser = Auth.auth().currentUser, !firebaseUser.isEmailVerified else {
            errorMessage = "ユーザーは既にメール認証済み、またはログインしていません。"
            return
        }

        firebaseUser.sendEmailVerification { [weak self] error in
            if let error = error {
                self?.errorMessage = "メール送信に失敗しました: \(error.localizedDescription)"
            } else {
                self?.updateSuccessMessage = "認証メールを再送しました。メールをご確認ください。"
            }
        }
    }
    
    func fetchCurrentUser() {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("現在のFirebaseユーザーが存在しません。")
            return
        }

        firebaseUser.reload { [weak self] error in  // 最新のユーザー情報を取得
            guard let self = self else { return }

            if let error = error {
                print("Error reloading user: \(error)")
            } else {
                self.currentUser = UserModel(uid: firebaseUser.uid, email: firebaseUser.email)
                self.isEmailVerified = firebaseUser.isEmailVerified
//                print("Updated isEmailVerified: \(self.isEmailVerified)")
                fetchAdditionalUserInfo(uid: firebaseUser.uid)
            }
        }
    }

    private func fetchAdditionalUserInfo(uid: String) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let username = data?["username"] as? String
                self?.currentUser?.username = username
            } else {
                print("Firestoreからの追加ユーザー情報の取得に失敗しました。")
            }
        }
    }
}
