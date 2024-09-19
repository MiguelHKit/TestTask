//
//  SingnUpView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI
import PhotosUI
import Combine

struct ImageData: Identifiable {
    let id = UUID()
    var uiImage: UIImage
    var jpegData: Data
    var fileSize: String
    
    static let empty: Self = .init(
        uiImage: .init(),
        jpegData: .init(),
        fileSize: ""
    )
}

enum SignUpFocusField {
    case name
    case email
    case phone
}

struct SignUpView: View {
    @StateObject var vm: SignUpViewModel = .init()
    //
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showPhotoConfirmationDialog: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showSuccessSignedUpModal: Bool = false
    @FocusState var focusedField: SignUpFocusField?
    @Environment(\.dismiss) var dissmissModal
    
    var body: some View {
        self.mainView
        .task(vm.getPositions)
        .animation(.easeIn, value: vm.isLoadingPositions)
        .loading(isLoading: vm.isLoading)
        .hideKeyboardOnTap()
        .onChange(of: self.focusedField){ _, newValue in
            vm.editingHasStarted = newValue != nil
        }
        .confirmationDialog("Choose how you want to add a photo", isPresented: $showPhotoConfirmationDialog, titleVisibility: .visible, actions: {
            Button("Camera") {
                
            }
            Button("Gallery") {
                self.showPhotoPicker = true
            }
        })
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) {
            _,
            newValue in
            Task {
                guard
                    let newItem: PhotosPickerItem = newValue,
                    let data = try? await newItem.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data),
                    let jpegData = uiImage.jpegData(compressionQuality: 1)
                else { return }
                let fileSize = uiImage.sizeInMB()
                self.vm.photo = .init(
                    uiImage: uiImage,
                    jpegData: jpegData,
                    fileSize: fileSize
                )
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
    var mainView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Working with POST request")
                    .font(.title2)
                Spacer()
            }
            .padding(.vertical)
            .background(.appYellow)
            .clipped()
            //
            ScrollView {
                VStack(
                    spacing: 30,
                    content: {
                        self.rowTextField(
                            placeholder: "Your Name",
                            value: $vm.name,
                            errorMsg: vm.nameErrorMsj,
                            focusValue: .name
                        )
                        .keyboardType(.alphabet)
                        .onSubmit { self.focusedField = .email }
                        self.rowTextField(
                            placeholder: "Email",
                            value: $vm.email,
                            errorMsg: vm.emailErrorMsj,
                            focusValue: .email
                        )
                        .onSubmit { self.focusedField = .phone }
                        .keyboardType(.emailAddress)
                        self.rowTextField(
                            placeholder: "Phone",
                            value: $vm.phone,
                            errorMsg: vm.phoneErrorMsj,
                            focusValue: .phone,
                            footer: "+38 (XXX) XXX - XX - XX"
                        )
                        .keyboardType(.phonePad)
                        .onSubmit { self.focusedField = nil }
                        .onChange(of: vm.phone) { _, newValue in
                            vm.phone = newValue.formatPhoneNumber()
                        }
                        // Positions row
                        if vm.isLoadingPositions {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.primary)
                                .padding(.vertical)
                        } else {
                            RadioSingleSelectionView(
                                selectedId: $vm.positionSelection,
                                items: vm.positionOptions,
                                titleLabel: "Select your position"
                            )
                        }
                        //
                        self.rowPhoto(
                            placeholder: "Upload your photo",
                            value: $vm.photo,
                            errorMsg: vm.photoNameErrorMsj,
                            uploadAction: {
                                self.showPhotoPicker = true
                            },
                            xmarkAction: {
                                vm.photo = nil
                            }
                        )
                        .loading(isLoading: vm.isLoadingPhoto)
                })
                .padding()
                //Button
                Button("Sign up") {
                    Task(operation: vm.submit)
                }
                .padding(.bottom)
                .buttonStyle(.appYellowButtonStyle)
                .disabledWhen($vm.sendButtonDisabled)
            }
        }
    }
    @ViewBuilder
    func rowTextField(placeholder: String, value: Binding<String>, errorMsg: String?, focusValue: SignUpFocusField? = nil, footer: String? = nil) -> some View {
        let tint: Color = errorMsg == nil ? .gray : .red
        let hasText: Bool = value.wrappedValue.isNotEmpty
        VStack(spacing: 10) {
            ZStack(alignment: .leading) {
                // Layer 1
                if !hasText {
                    Text(placeholder)
                        .foregroundStyle(tint)
                        .padding(.leading, 15)
                }
                //Layer 2
                TextField("", text: value)
                    .font(.subheadline)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: focusValue)
                    .padding(.horizontal,15)
                    .padding(.vertical, hasText ? 0 : 25)
                    .padding(.bottom, hasText ? 15 : 0)
                    .padding(.top, hasText ? 30 : 0)
                    .cornerRadius(10)
                    .overlay(
                        tint.opacity(0.7),
                        in: RoundedRectangle(
                            cornerRadius: 10
                        ).stroke(lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if hasText {
                            Text(placeholder)
                                .foregroundColor(tint)
                                .padding(.leading, 15)
                                .padding(.top, 10)
                                .font(.footnote)
                        }
                    }
            }
            .onTapGesture { self.focusedField = focusValue }
            if let errorMsg {
                HStack {
                    Text(errorMsg)
                    Spacer()
                }
                .font(.subheadline)
                .padding(.leading, 15)
                .foregroundStyle(.red)
            } else {
                if let footer {
                    HStack {
                        Text(footer)
                        Spacer()
                    }
                    .font(.footnote)
                    .padding(.leading, 15)
                    .foregroundStyle(tint)
                }
            }
        }
    }
    @ViewBuilder
    func rowPhoto(placeholder: String, value: Binding<ImageData?>, errorMsg: String?, uploadAction: @escaping () -> Void, xmarkAction: @escaping () -> Void) -> some View {
        let tint: Color = errorMsg == nil ? .gray : .red
        VStack {
            HStack {
                if let imageItem = value.wrappedValue {
                    Image(uiImage: imageItem.uiImage)
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text("\(imageItem.fileSize)")
                            .font(.subheadline)
                            .foregroundStyle(tint)
                    }
                    Spacer()
                    Button("", systemImage: "xmark", action: xmarkAction)
                } else {
                    Text(placeholder)
                        .foregroundColor(tint)
                    Spacer()
                    Button("Upload", action: uploadAction)
                    .foregroundStyle(.appCyan)
                    .padding(.trailing)
                }
            }
            .padding(.horizontal,15)
            .padding(.vertical,25)
            .cornerRadius(10)
            .overlay(
                tint.opacity(0.7),
                in: RoundedRectangle(
                    cornerRadius: 10
                ).stroke(lineWidth: 1)
            )
            if let errorMsg {
                HStack {
                    Text(errorMsg)
                    Spacer()
                }
                .font(.subheadline)
                .padding(.leading, 15)
                .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    MainView(tabSelection: .signUp)
}
