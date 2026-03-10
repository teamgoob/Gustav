//
//  LoginViewController.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit

final class LoginViewController: UIViewController {

    private let rootView = LoginView()
    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindActions()
        bindInput()
        bindDelegate()
        render()
    }
}

private extension LoginViewController {
    func bindActions() {
        rootView.formView.onTapSignIn = { [weak self] in
            guard let self else { return }

            Task { @MainActor in
                await self.viewModel.submitLogin()
                self.render()
            }
        }

        rootView.formView.onTapCreateAccount = { [weak self] in
            self?.viewModel.action(input: .tapCreateAccount)
        }

        rootView.formView.onTapForgotPassword = { [weak self] in
            self?.viewModel.action(input: .tapForgotPassword)
        }

        rootView.formView.onTapAppleLogin = { [weak self] in
            self?.viewModel.action(input: .tapAppleLogin)
        }
    }

    func bindInput() {
        rootView.formView.emailPasswordView.emailInputView.onTextChanged = { [weak self] text in
            self?.viewModel.action(input: .updateEmail(text))
            self?.render()
        }

        rootView.formView.emailPasswordView.passwordInputView.onTextChanged = { [weak self] text in
            self?.viewModel.action(input: .updatePassword(text))
            self?.render()
        }
    }

    func bindDelegate() {
        rootView.formView.emailPasswordView.emailTextField.delegate = self
        rootView.formView.emailPasswordView.passwordTextField.delegate = self
    }

    func render() {
        let output = viewModel.getCurrentOutput()

        rootView.formView.updateEmailError(output.emailErrorMessage)
        rootView.formView.updatePasswordError(output.passwordErrorMessage)
        rootView.formView.updateLoginButton(
            isEnabled: output.isLoginButtonEnabled,
            isLoading: output.isLoading
        )

        if output.isLoading {
            rootView.loadingView.startLoading()
        } else {
            rootView.loadingView.stopLoading()
        }
        
        rootView.formView.updateGeneralError(output.generalErrorMessage)
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let emailField = rootView.formView.emailPasswordView.emailTextField
        let passwordField = rootView.formView.emailPasswordView.passwordTextField

        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()

            Task { @MainActor in
                await viewModel.submitLogin()
                render()
            }
        }

        return true
    }
}
