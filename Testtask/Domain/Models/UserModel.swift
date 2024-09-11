//
//  UserModel.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import Foundation

struct UserModel: Hashable {
    let name: String
    let role: String
    let email: String
    let phoneNumber: String
    
    static let example: Self = .init(
        name: "Malcom Bailey",
        role: "Frontend developer",
        email: "email@email.com",
        phoneNumber: "+38 (098) 278 76 24"
    )
    static let examples: [Self] = .init(
        repeating: Self.example,
        count: 24
    )
}

extension Array where Element == UserModel {
    static let examples = UserModel.examples
}
