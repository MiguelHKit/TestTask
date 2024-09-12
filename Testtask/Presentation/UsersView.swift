//
//  UsersView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct UsersView: View {
    @State private var data: [UserModel] = []
    
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
    }
    
    @ViewBuilder
    var listView: some View {
        if data.isEmpty {
            AdviceView(
                image: .noUsers,
                title: "There are no user yet",
                button: nil
            )
        } else {
            List(self.data, id: \.self) { item in
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
