//  AppError.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AppError: LocalizedError {
    case notSignedIn
    case missingEmail
    case unknown

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "ログインが必要です。"
        case .missingEmail: return "メールアドレスが取得できませんでした。"
        case .unknown: return "エラーが発生しました。もう一度お試しください。"
        }
    }
}

extension Error {
    /// 画面に表示するためのメッセージ
    var userMessage: String {
        if let appError = self as? AppError {
            return appError.errorDescription ?? AppError.unknown.errorDescription!
        }

        let nsError = self as NSError
        if nsError.domain == AuthErrorDomain, let code = AuthErrorCode.Code(rawValue: nsError.code) {
            switch code {
            case .networkError: return "ネットワークに接続できません。通信環境を確認してください。"
            case .wrongPassword, .invalidCredential: return "メールアドレスまたはパスワードが正しくありません。"
            case .userNotFound: return "このメールアドレスのアカウントは見つかりません。"
            case .userDisabled: return "このアカウントは無効化されています。"
            case .emailAlreadyInUse: return "このメールアドレスは既に使用されています。"
            case .invalidEmail: return "メールアドレスの形式が正しくありません。"
            case .weakPassword: return "パスワードが弱すぎます。別のパスワードを設定してください。"
            case .tooManyRequests: return "試行回数が多すぎます。しばらく時間をおいてお試しください。"
            case .requiresRecentLogin: return "セキュリティのため、再度ログインしてからお試しください。"
            default: return "認証に失敗しました。入力内容を確認してください。"
            }
        }

        if nsError.domain == FirestoreErrorDomain, let code = FirestoreErrorCode.Code(rawValue: nsError.code) {
            switch code {
            case .unavailable, .deadlineExceeded: return "サーバーに接続できません。通信環境を確認してください。"
            case .permissionDenied, .unauthenticated: return "データへのアクセス権限がありません。再度ログインしてください。"
            default: break
            }
        }

        return AppError.unknown.errorDescription!
    }
}
