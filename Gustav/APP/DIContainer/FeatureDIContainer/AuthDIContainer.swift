
//
//  AuthDIContainer.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import Foundation

// MARK: - AuthDIContainerProtocol
protocol AuthDIContainerProtocol {
    func makeLoginViewModel(coordinator: any AuthCoordinatorProtocol) -> LoginViewModel
    func makeEmailSignUpViewModel(coordinator: any AuthCoordinatorProtocol) -> EmailSignUpViewModel
    func makeForgotPasswordViewModel(coordinator: any AuthCoordinatorProtocol) -> ForgotPasswordViewModel
}

// MARK: - AuthDIContainer
final class AuthDIContainer: AuthDIContainerProtocol {
    // MARK: - Properties
    private let authUseCase: AuthUseCaseProtocol
    
    // MARK: - Initializer
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
    
    // MARK: - ViewModel Builder
    func makeLoginViewModel(coordinator: any AuthCoordinatorProtocol) -> LoginViewModel {
        LoginViewModel(
            authUseCase: authUseCase,
            coordinator: coordinator
        )
    }
    
    func makeEmailSignUpViewModel(coordinator: any AuthCoordinatorProtocol) -> EmailSignUpViewModel {
        EmailSignUpViewModel(
            authUseCase: authUseCase,
            coordinator: coordinator
        )
    }

    func makeForgotPasswordViewModel(coordinator: any AuthCoordinatorProtocol) -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(
            authUseCase: authUseCase,
            coordinator: coordinator
        )
    }
}
