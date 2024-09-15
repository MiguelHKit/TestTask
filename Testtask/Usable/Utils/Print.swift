//
//  Print.swift
//  Testtask
//
//  Created by Miguel T on 13/09/24.
//

import Foundation

func log(_ value: Any?) {
#if DEBUG
    guard let value else { print("nil"); return }
    print(value)
#endif
}
func getPrettyJSONString(_ value: Data?) -> String {
    guard
        let value,
        let object = try? JSONSerialization.jsonObject(with: value, options: []),
        let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
        let prettyPrintedString = String(data: data, encoding: .utf8)
    else { return "nil" }
    return prettyPrintedString
}
func printPrettyJSON(_ value: Data?) {
#if DEBUG
    print(getPrettyJSONString(value))
#endif
}
