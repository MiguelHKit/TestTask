//
//  SingnUpView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI

enum SingUpResult {
    case success
    case emailAlreadyRegistered
}

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var nameErrorMsj: String? = nil
    @Published var email: String = ""
    @Published var emailErrorMsj: String? = nil
    @Published var phone: String = ""
    @Published var phoneErrorMsj: String? = nil
    @Published var positionSelection: String = ""
    @Published var positionOptions: [String] = [
        "Frontend developer",
        "Backend developer",
        "Designer developer",
        "QA",
    ]
    @Published var imageName: String = ""
    @Published var imageNameErrorMsj: String? = nil
    
    func signUp(onSuccessViewAction: () -> Void) {
        onSuccessViewAction()
    }
}

struct SignUpView: View {
    @StateObject var vm: SignUpViewModel = .init()
    //
    @State private var showSuccessSignedUpModal: Bool = false
    @Environment(\.dismiss) var dissmissModal
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Working with GET request")
                    .font(.title2)
                Spacer()
            }
            .padding(.vertical)
            .background(.appYellow)
            .clipped()
            //
            ScrollView {
                VStack(spacing: 30,
                       content: {
                    self.rowTextField(
                        placeholder: "Your Name",
                        value: $vm.name,
                        errorMsg: vm.nameErrorMsj
                    )
                    self.rowTextField(
                        placeholder: "Email",
                        value: $vm.email,
                        errorMsg: vm.emailErrorMsj
                    )
                    self.rowTextField(
                        placeholder: "Phone",
                        value: $vm.phone,
                        errorMsg: vm.phoneErrorMsj
                    )
                    //
                    RadioSingleSelectionView(
                        selectedItem: $vm.positionSelection,
                        items: vm.positionOptions,
                        titleLabel: "Select your position"
                    )
                    //
                    self.rowTextField(
                        placeholder: "Upload your photo",
                        value: $vm.imageName,
                        errorMsg: vm.imageNameErrorMsj
                    )
                    .overlay(alignment: .trailing) {
                        Button("Upload") {
                            
                        }
                        .foregroundStyle(.appCyan)
                        .padding(.trailing)
                    }
                })
                .padding()
                //Button
                Button("Sign up") {
                    vm.signUp(onSuccessViewAction: {
                        self.showSuccessSignedUpModal = true
                    })
                }
                .buttonStyle(.appYellowButtonStyle)
            }
        }
        .fullScreenCover(isPresented: self.$showSuccessSignedUpModal,
               content: {
            AdviceView(
                image: .successRegistered,
                title: "User succefully registered",
                button: .init(
                    buttonTitle: "Got it",
                    action: {
                        
                    }
                )
            )
            .overlay(alignment: .topTrailing) {
                Button("", systemImage: "xmark") {
                    showSuccessSignedUpModal = false
                }
                .foregroundStyle(.foreground)
                .opacity(0.8)
                .font(.title)
                .padding(.trailing)
            }
        })
    }
    @ViewBuilder
    func rowTextField(placeholder: String, value: Binding<String>, errorMsg: String?) -> some View {
        VStack(spacing: 10) {
            TextField(placeholder, text: value)
                .textFieldStyle(errorMsg == nil ? .grayBordered : .redBordered )
            if let errorMsg {
                HStack {
                    Text(errorMsg)
                    Spacer()
                }
                .font(.subheadline)
                .padding(.leading, 20)
                .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    SignUpView()
}
