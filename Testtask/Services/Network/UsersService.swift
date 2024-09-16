//
//  UsersService.swift
//  Testtask
//
//  Created by Miguel T on 12/09/24.
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

actor UserServices {
    let baseURL = NetworkManager.BASE_URL
    
    func submitUser() async throws -> Void {
        
    }
    
    func getUsers(page: Int, count: Int) async throws -> GetUsersResponse? {
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: self.baseURL,
                    version: .v1,
                    path: "users"
                ),
                method: .get,
                params: [
                    .init(name: "page", value: page.asString(), on: .query),
                    .init(name: "count", value: count.asString(), on: .query)
                ]
            )
        )
    }
    
    func getUser(id: Int) async throws -> GetUserResponse? {
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: self.baseURL,
                    version: .v1,
                    path: "users/\(id)"
                ),
                method: .get
            )
        )
    }
    
    func getPositions() async throws -> GetPositionsResponse? {
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: self.baseURL,
                    version: .v1,
                    path: "positions"
                ),
                method: .get
            )
        )
    }
    
    func getToken() async throws -> GetTokenResponse? {
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: self.baseURL,
                    version: .v1,
                    path: "token"
                ),
                method: .get
            )
        )
    }
}
