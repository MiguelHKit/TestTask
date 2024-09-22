//
//  UsersView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct UsersView: View {
    @StateObject var vm: UsersViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Working with GET request")
                    .font(.nunitoSans(size: 20))
                Spacer()
            }
            .padding(.vertical)
            .background(.appPrimary)
            .clipped()
            self.listView
        }
        .task(vm.onAppearTask)
        .refreshable(action: vm.onAppearTask)
        .loading(isLoading: vm.isLoading, isOpaque: true)
    }
    
    @ViewBuilder
    var listView: some View {
        if vm.data.isEmpty && !vm.isLoading {
            AdviceView(
                image: .noUsers,
                title: "There are no user yet",
                button: nil
            )
        } else {
            List(vm.data, id: \.self) { item in
                self.rowView(item: item)
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowSeparator(vm.data.last == item ? .hidden : .visible)
                // Progress to load pagination
                if vm.data.last == item && vm.hasMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .tint(.primary)
                    .offset(y: -10)
                    .padding(.bottom, 20)
                    .listRowSeparator(.hidden)
                    .task {
                        try? await Task.sleep(for: .seconds(1))
                        await vm.getUsers()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    @ViewBuilder
    func rowView(item: UserModel) -> some View {
        HStack(spacing: 15) {
            // Image
            VStack {
                AsyncImage(url: item.phoyoURL) { phase in
                    let grayCircle = Circle()
                        .frame(width: 50)
                        .foregroundStyle(.gray)
                    switch phase {
                    case .empty: grayCircle
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .clipShape(Circle())
                    case .failure(_): grayCircle
                    @unknown default: grayCircle
                    }
                }
                
                Spacer()
            }
            // Content
            VStack(alignment: .listRowSeparatorLeading, spacing: 0) {
                Text(item.name)
                    .font(.nunitoSans(size: 18))
                Group {
                    Text(item.role)
                        .opacity(0.6)
                        .padding(.top, 4)
                        .padding(.bottom, 10)
                    VStack(alignment: .listRowSeparatorLeading,spacing: 6) {
                        Text(item.email)
                            .lineLimit(1)
                        Text(item.phoneNumber)
                    }
                }
                .font(.nunitoSans(size: 14))
                Spacer()
            }
        }
        .padding(.top, 18)
//        .background(.red)
    }
}

#Preview {
    MainView(tabSelection: .users)
}
