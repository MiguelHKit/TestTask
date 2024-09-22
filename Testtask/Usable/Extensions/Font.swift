//
//  Font.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import SwiftUI


extension Font {
    static func nunitoSans(size: CGFloat = 16,  weight: Font.Weight = .regular) -> Font {
        let fontName = "NunitoSans10pt-"
        let weightName = switch weight {
        case .regular: "Regular"
        case .black: "Black"
        case .bold: "Bold"
        case .heavy: "ExtraBold"
        case .light: "Light"
        case .medium: "Medium"
        case .semibold: "Semibold"
        case .ultraLight, .thin: "ExtraLight"
        default: "Regular"
        }
        return .custom(fontName + weightName, size: size)
    }
}

#Preview(body: {
    VStack {
        Text("This is a normal font")
        Text("This is a diferent font")
            .font(.nunitoSans(size: 16, weight: .regular))
    }
//    .onAppear {
//        for family: String in UIFont.familyNames
//                {
//                    print(family)
//                    for names: String in UIFont.fontNames(forFamilyName: family)
//                    {
//                        print("== \(names)")
//                    }
//                }
//    }
})
