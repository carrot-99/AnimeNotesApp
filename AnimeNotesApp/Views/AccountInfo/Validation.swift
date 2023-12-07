//  Validation.swift

import Foundation

struct Validation {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    static func isValidPassword(_ password: String) -> Bool {
        let containsLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let containsDigit = password.range(of: "\\d", options: .regularExpression) != nil
        return password.count >= 8 && containsLetter && containsDigit
    }

    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
}
