//
//  LoadingModifier.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import SwiftUI

struct LoadingView: View {
    var isOpaque: Bool
    
    var body: some View {
        ZStack {
            Color.appBackground
                .opacity(isOpaque ? 0.2 : 1)
//                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(.primary)
        }
    }
}

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    var isOpaque: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                LoadingView(isOpaque: isOpaque)
            }
        }
    }
}

extension View {
    func loading(isLoading: Binding<Bool>, isOpaque: Bool = true) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading, isOpaque: isOpaque))
    }
}

#Preview {
    LoadingView(isOpaque: true)
}
