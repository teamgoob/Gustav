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
    // recovery 링크 이후 새 비밀번호 입력 화면 표시
    func showResetPassword()
    // 현재 화면 pop
    func pop()
}

import UIKit

final class AuthCoordinator: BaseCoordinator, AuthCoordinatorProtocol {
    private enum PolicyPage {
        static let termsURL = "https://dramatic-snipe-e53.notion.site/Gustav-Terms-of-Policy-31f1e18cef9c801e9811e0b55f555ab5"
        static let privacyURL = "https://dramatic-snipe-e53.notion.site/Gustav-Privacy-Policy-31f1e18cef9c801fb1d4c45cbc7ab321"
        static let termsTitle = "Terms of Policy"
        static let privacyTitle = "Privacy Policy"
    }

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

        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.setViewControllers([viewController], animated: false)
        
        viewController.onRoute = { [weak self] route in
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

        viewModel.onNavigation = { [weak self] route in
            switch route {
            case .showTerms:
                self?.showTermsPolicy()
            case .showPrivacy:
                self?.showPrivacyPolicy()
            case .pop:
                self?.pop()
            }
        }

        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showForgotPassword() {
        let viewModel = container.makeForgotPasswordViewModel()
        let viewController = ForgotPasswordViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)

    }

    func showResetPassword() {
        let viewModel = container.makeResetPasswordViewModel()
        let viewController = ResetPasswordViewController(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - Finish
    private func finish() {
        onFinish?(self)
    }

    func showTermsPolicy() {
        let viewController = WebpageViewController(
            urlString: PolicyPage.termsURL,
            title: PolicyPage.termsTitle
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    func showPrivacyPolicy() {
        let viewController = WebpageViewController(
            urlString: PolicyPage.privacyURL,
            title: PolicyPage.privacyTitle
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
