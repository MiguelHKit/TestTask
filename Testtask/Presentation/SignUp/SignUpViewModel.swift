//
//  SignUpViewModel.swift
//  Testtask
//
//  Created by Miguel T on 17/09/24.
//

import Foundation
import Combine

final class SignUpViewModel: ObservableObject, @unchecked Sendable {
    // Name Field
    @MainActor @Published var name: String = ""
    @Published var nameErrorMsj: String? = nil
    // Email Field
    @MainActor @Published var email: String = ""
    @Published var emailErrorMsj: String? = nil
    // Phone field
    @Published var phone: String = ""
    @Published var phoneErrorMsj: String? = nil
    // Position selection
    @Published var positionSelection: Int? = nil
    @MainActor @Published var positionOptions: [Dictionary<Int, String>.Element] = .init()
    // Photo field
    @Published var photo: ImageData? = nil
    @Published var photoNameErrorMsj: String? = nil
    //
    @Published var sendButtonDisabled: Bool = false
    @MainActor @Published var showSuccessSignedUpModal: Bool = false
    @MainActor @Published var serverErrorMessage: ErrorMessageItem? = nil
    // Loading var
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var isLoadingPositions: Bool = true
    @MainActor @Published var isLoadingPhoto: Bool = false
    private let services: UserServices = .init()
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Init
    init() {
        // Listen to fields for validation:
        self.$name
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .drop(while: { $0.isEmpty })
            .map { self.validateName($0) }
            .receive(on: RunLoop.main)
            .assign(to: \.nameErrorMsj, on: self)
            .store(in: &cancellables)
        self.$email
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .drop(while: { $0.isEmpty })
            .map { self.validateEmail($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.emailErrorMsj, on: self)
            .store(in: &cancellables)
        self.$phone
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .drop(while: { $0.isEmpty })
            .map { self.validatePhone($0) }
            .receive(on: RunLoop.main)
            .assign(to: \.phoneErrorMsj, on: self)
            .store(in: &cancellables)
        self.$photo
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .drop(while: { $0 == nil })
            .map { self.validatePhoto($0) }
            .receive(on: RunLoop.main)
            .assign(to: \.photoNameErrorMsj, on: self)
            .store(in: &cancellables)
        // Condition for enabling submit button
        self.$positionSelection.sink { [weak self] in
            self?.sendButtonDisabled = $0 == nil
        }
        .store(in: &cancellables)
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
    func validatePhoto(_ imageData: ImageData?) -> String? {
        guard
            let image = imageData?.uiImage,
            image.jpegData(compressionQuality: 1) != nil
        else { return "Photo is required" }
        return nil
    }
    func validateUser() async {
        // Trigger again validation listeners
        await MainActor.run {
            nameErrorMsj = validateName(self.name)
            emailErrorMsj = validateEmail(self.email)
            phoneErrorMsj = validatePhone(self.phone)
            photoNameErrorMsj = validatePhoto(self.photo)
        }
    }
    func resetView() {
        Task { @MainActor in
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
            self.serverErrorMessage = nil
            self.isLoading = false
            self.isLoadingPositions = true
            self.isLoadingPhoto = false
        }
        self.cancellables = []
        Task { await self.getPositions() }
    }
    // MARK: - Services
    @Sendable
    func getPositions() async {
        do {
            let response = try await self.services.getPositions()
            guard response.success == true
            else { throw NetworkError.custom(message: response.message.unwrap()) }
            // success, array to dictionary
            let positionOptionsDict: [Dictionary<Int,String>.Element] = Dictionary(
                uniqueKeysWithValues: response.positions
                    .compactMap {
                        guard
                            let id = $0?.id,
                            let name = $0?.name
                        else { return nil }
                        return (id, name)
                    }
                    .sorted(by: { $0.1 > $1.1 })
            ).sorted(by: { $0.key < $1.key })
            await print(positionOptions)
            await MainActor.run {
                self.positionOptions = positionOptionsDict
                self.isLoadingPositions = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingPositions = false
            }
        }
    }
    @Sendable
    func submit() async {
        await MainActor.run {
            self.isLoading = true
        }
        await self.validateUser()
        guard
            nameErrorMsj == nil,
            emailErrorMsj == nil,
            phoneErrorMsj == nil,
            photoNameErrorMsj == nil
        else {
            await MainActor.run {
                self.isLoading = false
            }
            return
        }
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
                await MainActor.run {
                    self.nameErrorMsj = registrationResponse.fails?.name?.mapToErrorMsj()
                    self.emailErrorMsj = registrationResponse.fails?.email?.mapToErrorMsj()
                    self.phoneErrorMsj = registrationResponse.fails?.phone?.mapToErrorMsj()
                    self.photoNameErrorMsj = registrationResponse.fails?.photo?.mapToErrorMsj()
                }
                throw NetworkError.custom(message: registrationResponse.message.unwrap())
            }
            // success
            await MainActor.run {
                self.isLoading = false
                self.showSuccessSignedUpModal = true
            }
        } catch NetworkError.custom(let message) {
            await MainActor.run {
                self.serverErrorMessage = .init(message: message)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
