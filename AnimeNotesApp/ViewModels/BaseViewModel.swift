//  BaseViewModel.swift

import Combine

class BaseViewModel: ObservableObject {
    @Published var error: IdentifiableError?
    var cancellables = Set<AnyCancellable>()

    // エラーバインディングの共通実装
    var hasError: Bool {
        get { error != nil }
        // 設定は具体的なビューモデルに委ねられる
        set { }
    }

    // エラーを表示するための共通のメソッド
    func displayError(message: String) {
        error = IdentifiableError(message: message)
    }
    
    // エラーをクリアするための共通のメソッド
    func clearError() {
        error = nil
    }
}

