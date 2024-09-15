//
//  Collection.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return startIndex <= index && index < endIndex ? self[index] : nil
    }
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
