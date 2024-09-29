//
//  UsersView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct UsersView: View {
    @StateObject var vm: UsersViewModel = .init()
    @State var progressViewId = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Top title
            TopTitleView(title: String(localized: "UsersView_title"))
            // List of users
            self.listView
        }
        .task(vm.onAppearTask)
        .refreshable(action: vm.onRefresableTask)
        .loading(isLoading: vm.isLoading, isOpaque: true)
    }
    // MARK: ListView
    @ViewBuilder
    var listView: some View {
        if vm.data.isEmpty && !vm.isLoading {
            AdviceView(
                image: .noUsers,
                title: String(localized:"no_users_message"),
                button: nil
            )
        } else {
            List(vm.data, id: \.self) { item in
                // Row for display each user
                self.rowView(item: item)
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowSeparator(vm.data.last == item ? .hidden : .visible)
                // ProgressView for loading pagination
                if vm.data.last == item && vm.hasMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .id(self.progressViewId)
                            .progressViewStyle(.circular)
                            .tint(.primary)
                            .scaleEffect(1.5)
                            .onAppear { progressViewId += 1 }
                        Spacer()
                    }
                    .offset(y: -10)
                    .padding(.bottom, 20)
                    .listRowSeparator(.hidden)
                    .task {
                        // Load more when progresView appears
                        try? await Task.sleep(for: .seconds(1))
                        await vm.onAppearTask()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    // MARK: placeholderImage
    @ViewBuilder
    var placeholderImage: some View {
        Image(.noPhoto)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
            .clipShape(Circle())
    }
    // MARK: RowView
    @ViewBuilder
    func rowView(item: UserModel) -> some View {
        HStack(spacing: 15) {
            // Image
            VStack {
                AsyncImage(url: item.phoyoURL) { phase in
                    switch phase {
                    case .empty: placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .clipShape(Circle())
                    case .failure(_): placeholderImage
                    @unknown default: placeholderImage
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
