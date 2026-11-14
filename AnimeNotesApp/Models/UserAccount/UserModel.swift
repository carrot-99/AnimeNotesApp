// UserModel.swift

import Foundation

struct UserModel: Equatable {
    let uid: String
    let email: String?
    var username: String?
    var isEmailVerified: Bool = false
}
