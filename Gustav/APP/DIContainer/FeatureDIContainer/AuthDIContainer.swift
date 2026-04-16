
//
//  AuthDIContainer.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import Foundation

// MARK: - AuthDIContainerProtocol
protocol AuthDIContainerProtocol {
    func makeLoginViewModel() -> LoginViewModel
    func makeEmailSignUpViewModel() -> EmailSignUpViewModel
    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel
    func makeResetPasswordViewModel() -> ResetPasswordViewModel
}

// MARK: - AuthDIContainer
final class AuthDIContainer: AuthDIContainerProtocol {

    
    // MARK: - AppDIContainer
    private let appDIContainer: AppDIContainer
    
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - ViewModel Builder
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authUseCase: appDIContainer.authUsecase
        )
    }
    func makeEmailSignUpViewModel() -> EmailSignUpViewModel {
        EmailSignUpViewModel(
            authUseCase: appDIContainer.authUsecase
        )
    }
    
    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(
            authUseCase: appDIContainer.authUsecase
        )
    }

    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        ResetPasswordViewModel(
            authUseCase: appDIContainer.authUsecase
        )
    }

}
