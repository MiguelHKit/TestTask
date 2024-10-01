//
//  UserModel.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import Foundation

struct UserModel: Hashable, Sendable {
    let id: Int
    let name: String
    let role: String
    let email: String
    let phoneNumber: String
    let phoyoURL: URL?
    
    static let example: Self = .init(
        id: 1,
        name: "Malcom Bailey",
        role: "Frontend developer",
        email: "email@email.com",
        phoneNumber: "+38 (098) 278 76 24",
        phoyoURL: URL(string: "")
    )
    static let examples: [Self] = .init(
        repeating: Self.example,
        count: 24
    )
}

extension Array where Element == UserModel {
    static let examples = UserModel.examples
}
