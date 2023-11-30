// UserModel.swift

import Foundation

struct UserModel {
    let uid: String
    let email: String?
    var username: String?
    var age: Int?
    
    // You may already have this initializer, adjust as needed
    init(uid: String, email: String?, username: String? = nil, age: Int? = nil) {
        self.uid = uid
        self.email = email
        self.username = username
        self.age = age
    }
}