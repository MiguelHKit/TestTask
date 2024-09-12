//
//  ContentView.swift
//  Testtask
//
//  Created by Miguel T on 10/09/24.
//

import SwiftUI

enum TabSelection {
    case users
    case signUp
}

struct MainView: View {
    @State var tabSelection: TabSelection = .users
    
    var body: some View {
        TabView(selection: $tabSelection) {
            // Users View
            UsersView()
                .tag(TabSelection.users)
                .tabItem { Label("Users", systemImage: "person.3.sequence.fill") }
            // SignUpView
            SignUpView()
                .tag(TabSelection.signUp)
                .tabItem { Label("Sign Up", systemImage: "person.crop.circle.fill.badge.plus") }
        }
        .tint(.appCyan)
    }
}

#Preview {
    MainView()
}
