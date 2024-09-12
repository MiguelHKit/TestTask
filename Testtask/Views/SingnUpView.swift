//
//  SingnUpView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

struct GrayBorderedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal,15)
            .padding(.vertical,20)
            .cornerRadius(10)
            .overlay(
                .gray,
                in: RoundedRectangle(
                    cornerRadius: 10
                ).stroke(lineWidth: 1)
            )
    }
}

struct RedBorderedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal,15)
            .padding(.vertical,20)
            .cornerRadius(10)
            .overlay(
                .red,
                in: RoundedRectangle(
                    cornerRadius: 10
                ).stroke(lineWidth: 1)
            )
    }
}

extension TextFieldStyle where Self == GrayBorderedTextFieldStyle {
    static var grayBordered: Self { Self() }
}

extension TextFieldStyle where Self == RedBorderedTextFieldStyle {
    static var redBordered: Self { Self() }
}

class SingnUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
}

struct SingnUpView: View {
    @StateObject var vm: SingnUpViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TextField("Your Name", text: .constant(""))
                    .textFieldStyle(.grayBordered)
                HStack {
                    Text("Validation Message")
                    Spacer()
                }
                .font(.subheadline)
                .padding(.leading, 20)
                .foregroundStyle(.red)
            }
        }
        .padding()
        VStack {
            Text("Select your position")
            HStack {
                
            }
        }
    }
}

#Preview {
    SingnUpView()
}
