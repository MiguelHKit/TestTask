//
//  LoadingModifier.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import SwiftUI


struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.appBackground
//                .opacity(0.2)
//                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(.primary)
        }
    }
}

struct LoadingModifier: ViewModifier {
    var isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                LoadingView()
            }
        }
    }
}

extension View {
    func loading(isLoading: Bool) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading))
    }
}

#Preview {
    LoadingView()
}
