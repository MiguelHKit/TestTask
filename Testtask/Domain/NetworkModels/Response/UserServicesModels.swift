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
    let total_pages: Int?
    let total_users: Int?
    let count: Int?
    let page: Int?
    let links: Self.Links?
    let users: [UserCodable?]
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
    let positions: [PositionItem]
    struct PositionItem: Codable {
        let id: Int?
        let name: String?
    }
}

struct GetTokenResponse: Codable {
    let success: Bool?
    let token: String?
}
