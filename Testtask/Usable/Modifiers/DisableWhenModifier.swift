//
//  DisableWhenModifier.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import SwiftUI

struct DisabledWhenModifier: ViewModifier {
    @Binding var condition: Bool
    
    func body(content: Content) -> some View {
        content
            .disabled(condition)
            .grayscale(condition ? 1 : 0)
            .opacity(condition ? 0.5 : 1)
    }
}

extension View {
    func disabledWhen(_ condition: Binding<Bool>) -> some View {
        self.modifier(DisabledWhenModifier(condition: condition))
    }
}

#Preview(body: {
    VStack {
        Button("Button") {
            
        }
        .buttonStyle(.appPrimaryFilledButtonStyle)
        .disabledWhen(.constant(true))
        
        Button("Button") {
            
        }
        .buttonStyle(.appPrimaryFilledButtonStyle)
        .disabledWhen(.constant(false))
    }
})
