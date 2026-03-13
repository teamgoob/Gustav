//
//  AuthCoordinator.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit

protocol AuthCoordinatorProtocol: AnyObject {
    func start() // 로그인 화면 시작
    func showEmailSignUp() // 회원가입 화면으로
    func pop() // 뒤로가기
    
    // 구현해야 하는 함수
    // showAppleSignIn()       // 애플 로그인

     func showForgotPassword()    // 비밀번호 찾기
    // func showMainApp()   // 메인화면으로 이동 (상위에 알림)
}


final class AuthCoordinator: AuthCoordinatorProtocol {

    private let navigationController: UINavigationController
    private let authUseCase: AuthUseCaseProtocol

    init(
        navigationController: UINavigationController,
        authUseCase: AuthUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.authUseCase = authUseCase
    }

    // 로그인 화면 시작
    func start() {
        let viewModel = LoginViewModel(
            authUseCase: authUseCase,
            coordinator: self
        )
        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    // 회원가입 화면으로 이동
    func showEmailSignUp() {
        let viewModel = EmailSignUpViewModel(
            authUseCase: authUseCase,
            coordinator: self
        )

        let viewController = EmailSignUpViewController(
            viewModel: viewModel
        )

        navigationController.pushViewController(viewController, animated: true)
    }

    func showForgotPassword() {
        let viewModel = ForgotPasswordViewModel(
            authUseCase: authUseCase,
            coordinator: self
        )

        let viewController = ForgotPasswordViewController(
            viewModel: viewModel
        )

        navigationController.pushViewController(viewController, animated: true)
    }


    // 뒤로가기
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
