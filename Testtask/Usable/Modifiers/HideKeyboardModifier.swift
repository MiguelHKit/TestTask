//
//  HideKeyboardModifier.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import SwiftUI
import UIKit

import Combine

@Observable
class KeyboardManager {
    nonisolated(unsafe) static let shared = KeyboardManager() // unsafe beause of Signleton
    //
    private var isKeyboardVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()

    private init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.global())
            .map { _ in true}
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.global())
            .map { _ in false }
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
    func hideKeyboard() {
        if self.isKeyboardVisible {
            Task { @MainActor in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(TapGesture().onEnded(KeyboardManager.shared.hideKeyboard))
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardModifier())
    }
}
