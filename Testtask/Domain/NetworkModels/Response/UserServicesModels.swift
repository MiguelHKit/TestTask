//
//  UserServicesModels.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

struct UserCodable: Codable {
    let id: Int?
    let name: String?
    let email: String?
    let phone: String?
    let position: String?
    let position_id: Int?
    let photo: String?
}

struct GetUsersResponse: Codable {
    let success: Bool?
    let totalPages: Int?
    let totalUsers: Int?
    let count: Int?
    let page: Int?
    let links: Self.Links?
    let users: [UserCodable?]
    let message: String?
    struct Links: Codable {
        let nextUrl: String?
        let prevUrl: String?
    }
}

struct GetUserResponse: Codable {
    let success: Bool?
    let user: UserCodable?
    let message: String?
    let fails: Self.Fails?
    struct Fails: Codable {
        let userId: [String?]
    }
}

struct GetPositionsResponse: Codable {
    let success: Bool?
    let positions: [PositionItem?]
    let message: String?
    struct PositionItem: Codable {
        let id: Int?
        let name: String?
    }
}

struct GetTokenResponse: Codable {
    let success: Bool?
    let token: String?
    let message: String?
}

struct UserRegistrationResponse: Codable {
    let success: Bool?
    let message: String?
    let fails: Self.Fails?
    struct Fails: Codable {
        let name: [String?]?
        let email: [String?]?
        let phone: [String?]?
        let position_Id: [String?]?
        let photo: [String?]?
    }
}
