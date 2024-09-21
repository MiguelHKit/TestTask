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
            .opacity(configuration.isPressed ? 0.5 : 1)
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
