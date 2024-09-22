//
//  AppYellowButtonStyle.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct PrimaryFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(configuration.isPressed ? .appPressedButton : .appPrimary)
            .clipShape(
                Capsule(),
                style: .init()
            )
            .font(.nunitoSans(size: 18, weight: .medium))
            .accentColor(.primary)
    }
}

extension ButtonStyle where Self == PrimaryFilledButtonStyle {
    static var appPrimaryFilledButtonStyle: Self { Self() }
}

#Preview {
    VStack {
        Button("Press me", action: {})
            .buttonStyle(.appPrimaryFilledButtonStyle)
    }
}
