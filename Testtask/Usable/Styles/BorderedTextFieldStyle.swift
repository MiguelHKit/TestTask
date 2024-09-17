//
//  BorderedTextFieldStyle.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct BorderedTextFieldStyle: TextFieldStyle {
    let tint: Color
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
//            .padding(.horizontal,15)
//            .padding(.vertical,20)
//            .cornerRadius(10)
//            .overlay(
//                tint.opacity(0.7),
//                in: RoundedRectangle(
//                    cornerRadius: 10
//                ).stroke(lineWidth: 1)
//            )
    }
    
    static let redBordered = BorderedTextFieldStyle(tint: .red)
    static let grayBordered = BorderedTextFieldStyle(tint: .gray)
}

extension TextFieldStyle where Self == BorderedTextFieldStyle {
    static var grayBordered: Self { Self.grayBordered }
    static var redBordered: Self { Self.redBordered }
}

#Preview(body: {
    VStack {
        TextField("Placeholder", text: .constant(""))
            .textFieldStyle(.grayBordered)
        TextField("Placeholder", text: .constant(""))
            .textFieldStyle(.redBordered)
        TextField("Placeholder", text: .constant(""))
            .textFieldStyle(.roundedBorder)
    }
    .padding()
})
