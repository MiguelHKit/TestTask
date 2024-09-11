//
//  AppYellowButtonStyle.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct AppYellowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(.appYellow)
            .clipShape(
                Capsule(),
                style: .init()
            )
            .fontWeight(.medium)
            .accentColor(.primary)
//            .scaleEffect(configuration.isPressed ? 1.2 : 1)
//            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == AppYellowButtonStyle {
    static var appYellowButtonStyle: Self { Self() }
}

#Preview {
    VStack {
        Button("Press me", action: {})
            .buttonStyle(.appYellowButtonStyle)
    }
}
