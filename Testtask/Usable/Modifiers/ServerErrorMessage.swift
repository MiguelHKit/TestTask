//
//  ServerErrorMessage.swift
//  Testtask
//
//  Created by Miguel T on 30/09/24.
//

import SwiftUI

struct ServerErrorMessage: ViewModifier {
    @Binding var errorMessage: ErrorMessageItem?
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(
                item: $errorMessage,
                content: { errorServer in
                    AdviceView(
                        image: .serverError,
                        title: errorServer.message,
                        button: .init(
                            buttonTitle: String(
                                localized: "try_again"),
                        action: {
                            if let action = errorServer.tryAgainAction {
                                action()
                                errorMessage = nil
                            } else {
                                errorMessage = nil
                            }
                        }
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Button("", systemImage: "xmark") {
                        errorMessage = nil
                    }
                    .foregroundStyle(.foreground)
                    .opacity(0.8)
                    .font(.title)
                    .padding(.top)
                    .padding(.trailing)
                }
            })
    }
}

extension View {
    func serverErrorMessage(errorMessage: Binding<ErrorMessageItem?>) -> some View {
        self.modifier(ServerErrorMessage(errorMessage: errorMessage))
    }
}

#Preview(body: {
    VStack {
        
    }
    .serverErrorMessage(errorMessage: .constant(.init(message: "Error")))
})
