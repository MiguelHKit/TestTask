//
//  SingnUpView.swift
//  Testtask
//
//  Created by Miguel T on 11/09/24.
//

import SwiftUI
import PhotosUI
import Combine

enum SignUpField: CaseIterable {
    case name
    case email
    case phone
    case photo
}

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var fields: [SignUpField] = SignUpField.allCases
    @Published var editingHasNotStarted: Bool = true
    @Published var name: String = ""
    @Published var nameErrorMsj: String? = nil
    @Published var email: String = ""
    @Published var emailErrorMsj: String? = nil
    @Published var phone: String = ""
    @Published var phoneErrorMsj: String? = nil
    @Published var positionSelection: String = ""
    @Published var positionOptions: [Int:String] = [:]
    @Published var photo: ImageData = .empty
    @Published var photoData: Data = .init()
    @Published var photoNameErrorMsj: String? = nil
    @Published var sendButtonDisabled: Bool = false
    //
    @Published var isSending: Bool = false
    private var services: UserServices = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // listen to field changes in order to display errors
        self.fields.forEach { field in
            switch field {
            case .name:
                self.$name
                    .drop(while: { [weak self] _ in
                        self?.editingHasNotStarted == true
                    })
                    .sink { [weak self] in
                        self?.nameErrorMsj = self?.validateName($0)
                    }.store(in: &cancellables)
            case .email:
                self.$email
                    .drop(while: { [weak self] _ in
                        self?.editingHasNotStarted == true
                    })
                    .sink { [weak self] in
                        self?.emailErrorMsj = self?.validateEmail($0)
                    }.store(in: &cancellables)
            case .phone:
                self.$phone
                    .drop(while: { [weak self] _ in
                        self?.editingHasNotStarted == true
                    })
                    .sink { [weak self] in
                        self?.phoneErrorMsj = self?.validatePhone($0)
                    }.store(in: &cancellables)
            case .photo:
                self.$photo
                    .drop(while: { [weak self] _ in
                        self?.editingHasNotStarted == true
                    })
                    .sink { [weak self] in
                        guard
                            $0.uiImage.jpegData(compressionQuality: 1) != nil
                        else { self?.phoneErrorMsj = "Photo is required"; return }
                        self?.phoneErrorMsj = nil
                    }.store(in: &cancellables)
            }
        }
        // condition for enabling submit button
        self.$positionSelection.sink { [weak self] in
            self?.sendButtonDisabled = $0.isEmpty
        }.store(in: &cancellables)
    }
    // MARK: - Validation
    func validateName(_ name: String) -> String? {
        return name.isEmpty ? "Required field" : nil
    }
    func validateEmail(_ email: String) -> String? {
        guard email.isNotEmpty else { return "email cannot be empty" }
        guard email.isEmail() else { return "invalid email format" }
        return nil
    }
    func validatePhone(_ name: String) -> String? {
        return phone.isEmpty ? "Required field" : nil
    }
    func validateUser() {
        self.editingHasNotStarted = true
        // Trigger again validation listeners
        self.name = self.name
        self.email = self.email
        self.phone = self.phone
        self.positionSelection = self.positionSelection
        self.photo = self.photo
    }
    // MARK: - Service
    func getPositions() async {
        do {
            let response = try await self.services.getPositions()
            guard response.success == true
            else { throw NetworkError.custom(message: response.message.unwrap()) }
            // success, array to dictionary
            self.positionOptions = Dictionary(
                uniqueKeysWithValues: response.positions.compactMap {
                    guard
                        let id = $0?.id,
                        let name = $0?.name
                    else { return nil }
                    return (id, name)
                }
            )
            
        } catch {
            
        }
    }
    @Sendable
    func submit() async {
        self.validateUser()
        guard
            nameErrorMsj == nil,
            emailErrorMsj == nil,
            phoneErrorMsj == nil,
            photoNameErrorMsj == nil
        else { return }
        do {
            // ask for token
            // submit Info
            // success
            self.isSending = true
        } catch {
            self.isSending = false
        }
        self.isSending = false
    }
}

struct ImageData: Identifiable {
    let id = UUID()
    var uiImage: UIImage
    var fileName: String
    var fileSize: Double
    
    static let empty: Self = .init(
        uiImage: .init(),
        fileName: "",
        fileSize: .zero
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
    @State private var showSuccessSignedUpModal: Bool = false
    @FocusState var focusedField: SignUpFocusField?
    @Environment(\.dismiss) var dissmissModal
    
    var body: some View {
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
                VStack(spacing: 30,
                       content: {
                    self.rowTextField(
                        placeholder: "Your Name",
                        value: $vm.name,
                        errorMsg: vm.nameErrorMsj,
                        focusValue: .name
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
                        value: $vm.photo.fileName,
                        errorMsg: vm.photoNameErrorMsj
                    ).disabled(true)
                    .overlay(alignment: .trailing) {
                        Button("Upload") {
                            self.showPhotoConfirmationDialog = true
                        }
                        .foregroundStyle(.appCyan)
                        .padding(.trailing)
                    }
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
        .hideKeyboardOnTap()
        .onChange(of: self.focusedField){ _, newValue in
            vm.editingHasNotStarted = newValue != nil
        }
        .confirmationDialog("Choose how you want to add a photo", isPresented: $showPhotoConfirmationDialog, titleVisibility: .visible, actions: {
            Button("Camera") {
                
            }
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    Text("Gallery")
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                            let fileSize = Double(data.count)
                            let fileName = newItem?.itemIdentifier ?? "Unknown"
                            let imageData = ImageData(
                                uiImage: uiImage,
                                fileName: fileName,
                                fileSize: fileSize
                            )
                        }
                    }
                }
        })
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
    func rowTextField(placeholder: String, value: Binding<String>, errorMsg: String?, focusValue: SignUpFocusField? = nil) -> some View {
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
    MainView(tabSelection: .signUp)
}
