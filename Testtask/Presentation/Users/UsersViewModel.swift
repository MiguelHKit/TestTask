//
//  UsersViewModel.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

final class UsersViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published
    var data: [UserModel] = []
    @MainActor @Published
    var isLoading: Bool = true
    @MainActor @Published
    var isRefreshing: Bool = false
    @MainActor @Published
    var serverErrorMessage: ErrorMessageItem? = nil
    @MainActor @Published
    var hasMore: Bool = false
    //
    var page: Int = 1
    var pageSize: Int = 6
    var userServices: UserServices = .init()
    //
    func loadUsers() async {
        do {
            try await self.getUsers()
            await MainActor.run {
                self.isLoading = false
            }
        } catch NetworkError.custom(let message) {
            await MainActor.run {
                self.serverErrorMessage = .init(message: message)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    func onRefresableTask() async {
        do {
            await MainActor.run {
                self.isRefreshing = true
                self.data = []
                self.hasMore = false
                self.page = 1
            }
            try await self.getUsers()
            await MainActor.run {
                self.isRefreshing = false
            }
        } catch NetworkError.custom(let message) {
            await MainActor.run {
                self.serverErrorMessage = .init(message: message)
                self.isRefreshing = false
            }
        } catch {
            await MainActor.run {
                self.isRefreshing = false
            }
        }
    }
    func getUsers() async throws {
        // call to network
        let response = try await self.userServices.getUsers(
            page: self.page,
            count: self.pageSize
        )
        guard response.success == true //bcs of optional
        else { throw NetworkError.custom(message: response.message.unwrap()) }
        // Mapping
        let nextUrl = response.links?.nextUrl ?? ""
        let totalPages = response.totalPages ?? 0
        let hasMore = nextUrl.isNotEmpty && self.page < totalPages
        let newUsers = response.users.compactMap { $0 }.map {
            UserModel(
                id: $0.id ?? 0,
                name: $0.name.unwrap(),
                role: $0.position.unwrap(),
                email: $0.email.unwrap(),
                phoneNumber: $0.phone.unwrap(),
                phoyoURL: URL(string: $0.photo ?? "")
            )
        }
        //
        await MainActor.run {
            self.data += newUsers
            self.page += 1
            self.hasMore = hasMore
        }
    }
}
