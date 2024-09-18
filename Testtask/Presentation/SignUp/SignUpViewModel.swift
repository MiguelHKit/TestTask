//
//  SignUpViewModel.swift
//  Testtask
//
//  Created by Miguel T on 17/09/24.
//

import Foundation
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
    @Published var editingHasStarted: Bool = false
    @Published var name: String = ""
    @Published var nameErrorMsj: String? = nil
    @Published var email: String = ""
    @Published var emailErrorMsj: String? = nil
    @Published var phone: String = ""
    @Published var phoneErrorMsj: String? = nil
    @Published var positionSelection: Int? = nil
    @Published var positionOptions: [Int:String] = [:]
    @Published var photo: ImageData? = nil
    @Published var photoData: Data = .init()
    @Published var photoNameErrorMsj: String? = nil
    @Published var sendButtonDisabled: Bool = false
    //
    @Published var isLoadingPositions: Bool = true
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
                        self?.editingHasStarted == false
                    })
                    .sink { [weak self] in
                        self?.nameErrorMsj = self?.validateName($0)
                    }.store(in: &cancellables)
            case .email:
                self.$email
                    .drop(while: { [weak self] _ in
                        self?.editingHasStarted == false
                    })
                    .sink { [weak self] in
                        self?.emailErrorMsj = self?.validateEmail($0)
                    }.store(in: &cancellables)
            case .phone:
                self.$phone
                    .drop(while: { [weak self] _ in
                        self?.editingHasStarted == false
                    })
                    .sink { [weak self] in
                        self?.phoneErrorMsj = self?.validatePhone($0)
                    }.store(in: &cancellables)
            case .photo:
                self.$photo
                    .drop(while: { [weak self] _ in
                        self?.editingHasStarted == false
                    })
                    .sink { [weak self] in
                        guard
                            let image = $0?.uiImage,
                            image.jpegData(compressionQuality: 1) != nil
                        else { self?.photoNameErrorMsj = "Photo is required"; return }
                        self?.photoNameErrorMsj = nil
                    }.store(in: &cancellables)
            }
        }
        // condition for enabling submit button
        self.$positionSelection.sink { [weak self] in
            self?.sendButtonDisabled = $0 == nil
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
        self.editingHasStarted = true
        // Trigger again validation listeners
        self.name = self.name
        self.email = self.email
        self.phone = self.phone
        self.positionSelection = self.positionSelection
        self.photo = self.photo
    }
    // MARK: - Service
    @Sendable
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
            self.isLoadingPositions = false
        } catch {
            self.isLoadingPositions = false
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
            self.isSending = true
            // ask for token
            guard let positionSelection, let photo else { throw NetworkError.localRequestError }
            let tokenResponse = try await self.services.getToken()
            guard tokenResponse.success == true else { throw NetworkError.custom(message: tokenResponse.message.unwrap()) }
            let resitrationResponse = try await self.services.userRegistration(
                token: tokenResponse.token.unwrap(),
                formData: [
                    .init(key: "name", value: .string(value: self.name)),
                    .init(key: "email", value: .string(value: self.email)),
                    .init(key: "phone", value: .string(value: self.phone)),
                    .init(key: "position_id", value: .string(value: positionSelection.description)),
                    .init(key: "photo", value: .data(fileData: photo.jpegData, fileName: "image.jpg", mimeType: .imageJpeg))
                ]
            )
            // submit Info
            // success
            self.isSending = true
        } catch {
            self.isSending = false
        }
        self.isSending = false
    }
}
