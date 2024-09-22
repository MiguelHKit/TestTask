//
//  AdviceView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct ButtonModel {
    let buttonTitle: String
    let action: () -> Void
}

struct AdviceView: View {
    var image: ImageResource
    var title: String
    var button: ButtonModel?
    
    var body: some View {
        ZStack(content: {
            Color.appBackground
            VStack(spacing: 20){
                Image(image)
                Text(title)
                    .font(.nunitoSans(size: 20))
                if let button = self.button {
                    Button(button.buttonTitle, action: button.action)
                        .buttonStyle(.appPrimaryFilledButtonStyle)
                }
            }
        })
    }
}

#Preview {
    AdviceView(
        image: .noConection,
        title: "There is no internet conection",
        button: .init(
            buttonTitle: "Try again",
            action: {  }
        )
    )
}
