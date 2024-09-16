//
//  Optional.swift
//  Testtask
//
//  Created by Miguel T on 15/09/24.
//

import Foundation

extension Optional where Wrapped == String {
    func unwrap() -> String {
        return self ?? ""
    }
    
    func unwrap(with string: String) -> String {
        return self ?? string
    }
}

//extension Optional where Wrapped == String? {
//    func unwrap() -> String {
//        self?.unwrap() ?? ""
//    }
//    func unwrap(with string: String) -> String {
//        return self?.unwrap(with: string) ?? string
//    }
//}
