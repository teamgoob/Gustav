//
//  ResetPasswordViewModel.swift
//  Gustav
//
//  Created by Kaeun on 2026/4/15.
//

import Foundation

@MainActor
final class ResetPasswordViewModel {

    var onDisplay: ((Output) -> Void)?
    var onEvent: ((Event) -> Void)?

    enum Input {
        case updatePassword(String)
        case updateRepeatPassword(String)
        case tapSubmit
        case tapBack
    }

    enum Event {
        case showError(String)
        case completeReset(String)
        case pop
    }

    struct Output {
        let passwordErrorMessage: String?
        let repeatPasswordErrorMessage: String?
        let isSubmitButtonEnabled: Bool
        let isLoading: Bool
    }

    private struct State {
        var password: String = ""
        var repeatPassword: String = ""
        var isLoading: Bool = false
    }

    private let authUseCase: AuthUseCaseProtocol
    private let validator: AuthValidatorProtocol
    private var state = State()

    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.validator = DefaultAuthValidator()
    }

    func action(input: Input) async {
        switch input {
        case .updatePassword(let password):
            updateState {
                state.password = password
            }
        case .updateRepeatPassword(let repeatPassword):
            updateState {
                state.repeatPassword = repeatPassword
            }
        case .tapSubmit:
            await submitPasswordReset()
        case .tapBack:
            onEvent?(.pop)
        }
    }

    func getCurrentOutput() -> Output {
        let passwordError = shouldShowPasswordError
            ? validator.validatePassword(state.password, minLength: 8)
            : nil
        let repeatPasswordError = shouldShowRepeatPasswordError
            ? validator.validateRepeatPassword(
                password: state.password,
                repeatPassword: state.repeatPassword
            )
            : nil

        return Output(
            passwordErrorMessage: mapInputErrorToMessage(passwordError),
            repeatPasswordErrorMessage: mapInputErrorToMessage(repeatPasswordError),
            isSubmitButtonEnabled: canSubmit(),
            isLoading: state.isLoading
        )
    }
}

private extension ResetPasswordViewModel {
    var shouldShowPasswordError: Bool {
        !state.password.isEmpty
    }

    var shouldShowRepeatPasswordError: Bool {
        !state.repeatPassword.isEmpty
    }

    func updateState(_ updates: () -> Void) {
        updates()
        notifyOutput()
    }

    func notifyOutput() {
        onDisplay?(getCurrentOutput())
    }

    func canSubmit() -> Bool {
        guard !state.isLoading else { return false }

        let passwordError = validator.validatePassword(state.password, minLength: 8)
        let repeatPasswordError = validator.validateRepeatPassword(
            password: state.password,
            repeatPassword: state.repeatPassword
        )

        return passwordError == nil && repeatPasswordError == nil
    }

    func submitPasswordReset() async {
        let passwordError = validator.validatePassword(state.password, minLength: 8)
        let repeatPasswordError = validator.validateRepeatPassword(
            password: state.password,
            repeatPassword: state.repeatPassword
        )

        guard passwordError == nil, repeatPasswordError == nil else {
            notifyOutput()
            return
        }

        updateState {
            state.isLoading = true
        }

        let result = await authUseCase.updatePassword(newPassword: state.password)

        switch result {
        case .success:
            updateState {
                state.isLoading = false
            }
            onEvent?(.completeReset("Your password has been updated."))

        case .failure(let error):
            updateState {
                state.isLoading = false
            }
            onEvent?(.showError(mapDomainErrorToMessage(error)))
        }
    }

    func mapInputErrorToMessage(_ error: AuthInputError?) -> String? {
        guard let error else { return nil }

        switch error {
        case .emptyPassword:
            return nil
        case .emptyRepeatPassword:
            return nil
        case .passwordTooShort(let minLength):
            return "Password must be \(minLength) or more characters."
        case .passwordMissingLetterOrDigit:
            return "Password must include both letters and digits."
        case .passwordMismatch:
            return "Passwords do not match."
        case .invalidEmailFormat, .emptyEmail:
            return nil
        }
    }

    func mapDomainErrorToMessage(_ error: DomainError) -> String {
        switch error {
        case .authenticationRequired:
            return "This recovery link is no longer valid. Please request a new one."
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

        case .invalidCredentials:
            return "This recovery link is no longer valid. Please request a new one."

        case .rateLimited:
            return "Too many attempts. Please wait a moment and try again."

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
