//
//  UsersService.swift
//  Testtask
//
//  Created by Miguel T on 12/09/24.
//

import Foundation

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
