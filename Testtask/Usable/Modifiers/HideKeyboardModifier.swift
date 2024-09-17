//
//  HideKeyboardModifier.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import SwiftUI
import UIKit

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardModifier())
    }
}
