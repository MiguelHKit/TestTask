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
                Text("Working with GET request")
            }
            .background(.appYellow)
            self.listView
        }
    }
    
    @ViewBuilder
    var listView: some View {
        if data.isEmpty {
            Text("No data")
        } else {
            List(self.data, id: \.self) { item in
                self.rowView(item: item)
            }
        }
    }
    @ViewBuilder
    func rowView(item: UserModel) -> some View {
        VStack {
            Text("Name")
            Text("Role")
            Text("E-mail")
            Text("Phone number")
        }
    }
}

#Preview {
    MainView(tabSelection: .users)
}
