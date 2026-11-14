//  Validation.swift

import Foundation

enum Validation {
    static let usernameMaxLength = 20

    struct Requirement: Identifiable {
        let label: String
        let isSatisfied: Bool
        var id: String { label }
    }

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func passwordRequirements(_ password: String) -> [Requirement] {
        [
            Requirement(label: "8文字以上", isSatisfied: password.count >= 8),
            Requirement(label: "英字を含む", isSatisfied: password.range(of: "[A-Za-z]", options: .regularExpression) != nil),
            Requirement(label: "数字を含む", isSatisfied: password.range(of: "[0-9]", options: .regularExpression) != nil)
        ]
    }

    static func isValidPassword(_ password: String) -> Bool {
        passwordRequirements(password).allSatisfy(\.isSatisfied)
    }

    static func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= usernameMaxLength
    }
}
