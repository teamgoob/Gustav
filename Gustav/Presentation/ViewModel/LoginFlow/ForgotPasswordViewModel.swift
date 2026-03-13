
//
//  ForgotPasswordViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/13/26.
//

import Foundation

@MainActor
final class ForgotPasswordViewModel {

    // MARK: - Output Binding
    var onOutputChanged: (() -> Void)?

    // MARK: - Event
    var onEvent: ((Event) -> Void)?

    // MARK: - Input
    enum Input {
        case updateEmail(String)
        case tapSendVerificationMail
        case tapBack
    }

    // MARK: - Event Type
    enum Event {
        case showError(String)
        case showSuccess(String)
        case pop
    }

    // MARK: - Output Model
    struct Output {
        let emailErrorMessage: String?
        let isSendButtonEnabled: Bool
        let isLoading: Bool
    }

    // MARK: - Internal State
    private struct State {
        var email: String = ""
        var isLoading: Bool = false
    }

    // MARK: - Dependencies
    private let authUseCase: AuthUseCaseProtocol
    private weak var coordinator: AuthCoordinatorProtocol?
    private let validator: AuthValidatorProtocol

    // MARK: - State
    private var state = State()

    // MARK: - Initializer
    init(
        authUseCase: AuthUseCaseProtocol,
        coordinator: AuthCoordinatorProtocol?,
        validator: AuthValidatorProtocol
    ) {
        self.authUseCase = authUseCase
        self.coordinator = coordinator
        self.validator = validator
    }

    init(
        authUseCase: AuthUseCaseProtocol,
        coordinator: AuthCoordinatorProtocol?
    ) {
        self.authUseCase = authUseCase
        self.coordinator = coordinator
        self.validator = DefaultAuthValidator()
    }

    // MARK: - State Update
    private func updateState(_ updates: () -> Void) {
        updates()
        onOutputChanged?()
    }

    // MARK: - Input Handling
    func action(input: Input) async {
        switch input {
        case .updateEmail(let email):
            updateState {
                state.email = email
            }

        case .tapSendVerificationMail:
            await submitResetPassword()

        case .tapBack:
            onEvent?(.pop)
        }
    }

    // MARK: - Output Mapping
    func getCurrentOutput() -> Output {
        let emailError = shouldShowEmailError
            ? validator.validateEmail(state.email)
            : nil

        return Output(
            emailErrorMessage: mapInputErrorToMessage(emailError),
            isSendButtonEnabled: canSubmitResetPassword(),
            isLoading: state.isLoading
        )
    }
}

private extension ForgotPasswordViewModel {

    // MARK: - Validation Helpers
    var shouldShowEmailError: Bool {
        !state.email.isEmpty
    }

    func canSubmitResetPassword() -> Bool {
        guard !state.isLoading else { return false }
        return validator.validateEmail(state.email) == nil
    }

    // MARK: - Reset Password Logic
    func submitResetPassword() async {
        let emailError = validator.validateEmail(state.email)

        guard emailError == nil else {
            onOutputChanged?()
            return
        }

        updateState {
            state.isLoading = true
        }

        let result = await authUseCase.resetPassword(email: state.email)

        switch result {
        case .success:
            updateState {
                state.isLoading = false
            }
            onEvent?(.showSuccess("Check your email for the password reset link."))

        case .failure(let error):
            updateState {
                state.isLoading = false
            }
            onEvent?(.showError(mapDomainErrorToMessage(error)))
        }
    }

    // MARK: - Error Mapping
    func mapInputErrorToMessage(_ error: AuthInputError?) -> String? {
        guard let error else { return nil }

        switch error {
        case .invalidEmailFormat:
            return "Invalid email format."

        case .emptyEmail:
            return nil

        case .emptyPassword,
             .emptyRepeatPassword,
             .passwordTooShort,
             .passwordMissingSpecialCharacter,
             .passwordMismatch:
            return nil
        }
    }

    func mapDomainErrorToMessage(_ error: DomainError) -> String {
        switch error {
        case .authenticationRequired:
            return "Authentication is required."

        case .permissionDenied:
            return "Permission denied."

        case .entityNotFound:
            return "Account not found."

        case .invalidOperation:
            return "Invalid operation."

        case .invalidParameter:
            return "Invalid parameter."

        case .invalidInput(let inputError):
            return mapInputErrorToMessage(inputError) ?? "Invalid input."

        case .temporarilyUnavailable:
            return "Temporary server error. Please try again."

        case .cancelled:
            return "The operation was cancelled."

        case .unknown:
            return "An unknown error occurred."

        case .emailAlreadyInUse:
            return "This email is already in use."
        }
    }
}
