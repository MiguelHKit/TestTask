//
//  UIAplication.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import UIKit

extension UIApplication {
    func endEditing() {
        if let windowScene = connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.endEditing(true)
        }
    }
}
