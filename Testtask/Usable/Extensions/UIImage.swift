//
//  UIImage.swift
//  Testtask
//
//  Created by Miguel T on 18/09/24.
//

import UIKit

extension UIImage {
    func sizeInMB() -> String {
        guard let imageData = self.pngData() else { return "0 MB" } // O usa jpegData(compressionQuality:) si prefieres JPEG
        let sizeInBytes = Double(imageData.count)
        let sizeInMB = sizeInBytes / (1024 * 1024) // Convierte a MB
        return String(format: "%.2f MB", sizeInMB) // Formato a 2 decimales
    }
}
