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
    @StateObject var vm: MainViewModel = .init()
    
    var body: some View {
        TabView(selection: $tabSelection) {
            // Users View
            UsersView()
                .tag(TabSelection.users)
                .tabItem { Label(String(localized: "users") , systemImage: "person.3.sequence.fill") }
            // SignUpView
            SignUpView()
                .tag(TabSelection.signUp)
                .tabItem { Label(String(localized: "sign_up"), systemImage: "person.crop.circle.fill.badge.plus") }
        }
        .tint(.appSecondary)
        .fullScreenCover(isPresented: $vm.isNotConected) {
            AdviceView(
                image: .noConection,
                title: String(
                    localized: "no_conection_message"),
                button: .init(
                    buttonTitle: String(
                        localized: "try_again"),
                    action: vm.retry
                )
            )
        }
    }
}

#Preview {
    MainView()
}
