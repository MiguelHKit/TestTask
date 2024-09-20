//
//  SignUpViewModel.swift
//  Testtask
//
//  Created by Miguel T on 17/09/24.
//

import Foundation
import Combine

@MainActor
class SignUpViewModel: ObservableObject {
    // Name Field
    @Published var name: String = ""
    @Published var nameErrorMsj: String? = nil
    // Email Field
    @Published var email: String = ""
    @Published var emailErrorMsj: String? = nil
    // Phone field
    @Published var phone: String = ""
    @Published var phoneErrorMsj: String? = nil
    // Position selection
    @Published var positionSelection: Int? = nil
    @Published var positionOptions: [Int:String] = [:]
    // Photo field
    @Published var photo: ImageData? = nil
    @Published var photoNameErrorMsj: String? = nil
    //
    @Published var editingHasStarted: Bool = false
    @Published var sendButtonDisabled: Bool = false
    @Published var showSuccessSignedUpModal: Bool = false
    @Published var serverErroMessage: ErrorMessageItem? = nil
    // Loading var
    @Published var isLoading: Bool = false
    @Published var isLoadingPositions: Bool = true
    @Published var isLoadingPhoto: Bool = false
    private var services: UserServices = .init()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to this field changes
        self.$name
            .drop(while: { [weak self] _ in
                self?.editingHasStarted == false
            })
            .sink { [weak self] in
                self?.nameErrorMsj = self?.validateName($0)
            }.store(in: &cancellables)
        self.$email
            .drop(while: { [weak self] _ in
                self?.editingHasStarted == false
            })
            .sink { [weak self] in
                self?.emailErrorMsj = self?.validateEmail($0)
            }.store(in: &cancellables)
        self.$phone
            .drop(while: { [weak self] _ in
                self?.editingHasStarted == false
            })
            .sink { [weak self] in
                self?.phoneErrorMsj = self?.validatePhone($0)
            }.store(in: &cancellables)
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
        // Cndition for enabling submit button
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
        guard email.isEmailRFC2822() else { return "invalid email format" }
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
    func resetView() {
        self.editingHasStarted = false
        self.name = ""
        self.nameErrorMsj = nil
        self.email = ""
        self.emailErrorMsj = nil
        self.phone = ""
        self.phoneErrorMsj = nil
        self.positionSelection = nil
        self.photo = nil
        self.photoNameErrorMsj = nil
        self.sendButtonDisabled = false
        self.showSuccessSignedUpModal = false
        self.serverErroMessage = nil
        self.isLoading = false
        self.isLoadingPositions = true
        self.isLoadingPhoto = false
        Task { await self.getPositions() }
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
        self.isLoading = true
        self.validateUser()
        guard
            nameErrorMsj == nil,
            emailErrorMsj == nil,
            phoneErrorMsj == nil,
            photoNameErrorMsj == nil
        else { self.isLoading = false; return }
        do {
            // ask for token
            guard let positionSelection, let photo else { throw NetworkError.localRequestError }
            let tokenResponse = try await self.services.getToken()
            guard tokenResponse.success == true else { throw NetworkError.custom(message: tokenResponse.message.unwrap()) }
            var phoneFinalFormat = self.phone.cleanPhoneNumber()
            phoneFinalFormat.insert("+", at: phoneFinalFormat.startIndex)
            let registrationResponse = try await self.services.userRegistration(
                token: tokenResponse.token.unwrap(),
                formData: [
                    .init(key: "name", value: .string(value: self.name)),
                    .init(key: "email", value: .string(value: self.email)),
                    .init(key: "phone", value: .string(value: phoneFinalFormat)),
                    .init(key: "position_id", value: .string(value: positionSelection.description)),
                    .init(key: "photo", value: .data(fileData: photo.jpegData, mimeType: .imageJpeg))
                ]
            )
            // submit Info
            guard registrationResponse.success == true else {
                self.nameErrorMsj = registrationResponse.fails?.name?.mapToErrorMsj()
                self.emailErrorMsj = registrationResponse.fails?.email?.mapToErrorMsj()
                self.phoneErrorMsj = registrationResponse.fails?.phone?.mapToErrorMsj()
                self.photoNameErrorMsj = registrationResponse.fails?.photo?.mapToErrorMsj()
                self.editingHasStarted = false // Reset edit status
                throw NetworkError.custom(message: registrationResponse.message.unwrap())
            }
            // success
            self.isLoading = false
            self.showSuccessSignedUpModal = true
        } catch NetworkError.custom(let message) {
            self.serverErroMessage = .init(message: message)
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
}
