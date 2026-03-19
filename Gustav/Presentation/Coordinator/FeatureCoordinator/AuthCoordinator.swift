//
//  AuthCoordinator.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

// MARK: - AuthCoordinating
protocol AuthCoordinatorProtocol: Coordinator {
    // 로그인 플로우 시작
    func start()
    // 로그인 화면 표시
    func showLogin()
    // 이메일 회원가입 화면 표시
    func showEmailSignUp()
    // 비밀번호 찾기 화면 표시
    func showForgotPassword()
    // 현재 화면 pop
    func pop()
}


import UIKit

final class AuthCoordinator: BaseCoordinator, AuthCoordinatorProtocol {
    private let container: AuthDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    
    init(
        navigationController: UINavigationController,
        container: AuthDIContainer
    ) {
        self.container = container
        super.init(navigationController: navigationController)
    }

    override func start() {
        showLogin()
    }
    
    // MARK: - Auth Flow
    func showLogin() {
        print("AuthCoordinator.showLogin called")

        let viewModel = container.makeLoginViewModel()
        let viewController = LoginViewController(viewModel: viewModel)

        print("LoginViewController created")

        navigationController.setViewControllers([viewController], animated: false)
        
        viewModel.onNavigation = { [weak self] route in
            switch route {
            case .showEmailSignUp:
                self?.showEmailSignUp()

            case .showForgotPassword:
                self?.showForgotPassword()
            }
        }
        print("LoginViewController set")
    }
    
    func showEmailSignUp() {
        let viewModel = container.makeEmailSignUpViewModel()
        let viewController = EmailSignUpViewController(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showForgotPassword() {
        let viewModel = container.makeForgotPasswordViewModel()
        let viewController = ForgotPasswordViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)

    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - Finish
    private func finish() {
        onFinish?(self)
    }
}
