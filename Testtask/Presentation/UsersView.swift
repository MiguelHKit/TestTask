//
//  UsersView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

@MainActor
class UsersViewModel: ObservableObject {
    @Published var data: [UserModel] = []
    var userServices: UserServices = .init()
    
    @Sendable
    func onAppearTask() async {
        await self.getUsers()
    }
    func getUsers() async {
        do {
            // call to network
            guard
                let response = try await self.userServices.getUsers(
                    page: 2,
                    count: 10
                ),
                response.success == true //bcs of optional
            else { throw NetworkError.dataError }
            self.data = response.users.compactMap { $0 }.map {
                UserModel(
                    name: $0.name.unwrap(),
                    role: $0.position.unwrap(),
                    email: $0.email.unwrap(),
                    phoneNumber: $0.phone.unwrap()
                )
            }
        } catch {
            print("getUsers: \(error)")
        }
    }
}

struct UsersView: View {
    @StateObject var vm: UsersViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Working with GET request")
                    .font(.title2)
                Spacer()
            }
            .padding(.vertical)
            .background(.appYellow)
            .clipped()
            self.listView
        }
        .task(vm.onAppearTask)
    }
    
    @ViewBuilder
    var listView: some View {
        if vm.data.isEmpty {
            AdviceView(
                image: .noUsers,
                title: "There are no user yet",
                button: nil
            )
        } else {
            List(vm.data, id: \.self) { item in
                self.rowView(item: item)
            }
            .listStyle(.plain)
        }
    }
    @ViewBuilder
    func rowView(item: UserModel) -> some View {
        HStack(spacing: 15) {
            VStack {
                Circle()
                    .frame(width: 50)
                    .foregroundStyle(.gray)
                Spacer()
            }
            VStack(alignment: .listRowSeparatorLeading) {
                Text(item.name)
                    .font(.title3)
                Group {
                    Text(item.role)
                        .opacity(0.6)
                        .padding(.bottom, 5)
                    Text(item.email)
                        .lineLimit(1)
                    Text(item.phoneNumber)
                }
                .font(.subheadline)
                Spacer()
            }
        }
        .padding(.top, 20)
//        .background(.red)
    }
}

#Preview {
    MainView(tabSelection: .users)
}
