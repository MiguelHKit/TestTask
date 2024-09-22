//
//  SecondaryTextButtonStyle.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import SwiftUI
struct SecondaryTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            configuration.label
                .font(.nunitoSans(size: 18))
                .foregroundStyle(.appSecondary)
                .padding(10)
                .background(.appSecondary.opacity(0.1))
                .clipShape(Capsule())
        } else {
            configuration.label
                .font(.nunitoSans(size: 18, weight: .semibold))
                .foregroundStyle(.appSecondary)
                .padding(10)
                .clipShape(Capsule())
        }
    }
}

extension ButtonStyle where Self == SecondaryTextButtonStyle {
    static var appSecondaryTextButtonStyle: Self { Self() }
}

#Preview {
    VStack {
        Button("Press me", action: {})
            .buttonStyle(.appSecondaryTextButtonStyle)
    }
}
