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
//    func removeOptionals() -> [Element] {
//        self.compactMap { $0 }
//    }
}

extension Array where Element: ExpressibleByNilLiteral {
    // Función que elimina los valores nil
    func removeOptionals() -> [Element] {
        return self.compactMap { $0 }
    }
}

extension Array where Element == String? {
    func mapToErrorMsj() -> String? {
        let array = self.compactMap{ $0 }
        if array.isEmpty { return nil }
        else {return array.joined(separator: "\n")}
    }
}
