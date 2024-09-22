//
//  UsersViewModel.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

@MainActor
class UsersViewModel: ObservableObject {
    @Published var data: [UserModel] = []
    @Published var isLoading: Bool = true
    @Published var isLoadingPagination: Bool = true
    @Published var page: Int = 0
    @Published var pageSize: Int = 6
    @Published var hasMore: Bool = false
    var userServices: UserServices = .init()
    
    @Sendable
    func onAppearTask() async {
        await self.getUsers()
    }
    func getUsers() async {
        do {
            // call to network
            let response = try await self.userServices.getUsers(
                page: self.page + 1,
                count: self.pageSize
            )
            guard response.success == true //bcs of optional
            else { throw NetworkError.custom(message: response.message.unwrap()) }
            // Mapping
            self.hasMore = response.links?.nextUrl != nil
            let newUsers = response.users.compactMap { $0 }.map {
                UserModel(
                    id: $0.id ?? 0,
                    name: $0.name.unwrap(),
                    role: $0.position.unwrap(),
                    email: $0.email.unwrap(),
                    phoneNumber: $0.phone.unwrap(),
                    phoyoURL: URL(string: $0.photo.unwrap())
                )
            }
            //
            self.data += newUsers
            self.page += 1
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
}
