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
    
    var onRoute: ((LoginViewModel.Route) -> Void)?

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
        setupDelegate()
        bindViewModel()
        bindActions()
        bindInput()
        setupGesture()
        viewModel.action(input: .updateEmail(""))
    }
}

private extension LoginViewController {
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        
        viewModel.onNavigation = { [weak self] route in
            self?.onRoute?(route)
        }
    }

    func bindActions() {
        print("bindActions called")
        rootView.formView.onTapSignIn = { [weak self] in
            guard let self else { return }

            Task { @MainActor in
                await self.viewModel.submitLogin()
            }
        }

        rootView.formView.onTapCreateAccount = { [weak self] in
            self?.viewModel.action(input: .tapCreateAccount)
        }

        rootView.formView.onTapForgotPassword = { [weak self] in
            self?.viewModel.action(input: .tapForgotPassword)
        }

        rootView.formView.onTapAppleLogin = { [weak self] in
            guard let self else { return }

            Task { @MainActor in
                await self.viewModel.handleAppleLogin()
            }
        }
    }

    func bindInput() {
        rootView.formView.emailPasswordView.emailInputView.onTextChanged = { [weak self] text in
            self?.viewModel.action(input: .updateEmail(text))
        }

        rootView.formView.emailPasswordView.passwordInputView.onTextChanged = { [weak self] text in
            self?.viewModel.action(input: .updatePassword(text))
        }
    }

    func setupDelegate() {
        rootView.formView.emailPasswordView.emailTextField.delegate = self
        rootView.formView.emailPasswordView.passwordTextField.delegate = self
    }

    func apply(_ output: LoginViewModel.Output) {
        rootView.formView.updateEmailError(output.emailErrorMessage)
        rootView.formView.updatePasswordError(output.passwordErrorMessage)
        
        let isLoading: Bool
        switch output.isLoading {
        case .loading(let text):
            isLoading = true
            rootView.loadingView.startLoading(with: text)
        case .notLoading:
            isLoading = false
            rootView.loadingView.stopLoading()
        }
        
        rootView.formView.updateLoginButton(
            isEnabled: output.isLoginButtonEnabled,
            isLoading: isLoading
        )
        
        rootView.formView.updateGeneralError(output.generalErrorMessage)
        
        if let message = output.generalErrorMessage {
            showErrorAlert(message)
        }
    }
    
    // 키보드 내리기
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showErrorAlert(_ message: String) {
        guard presentedViewController == nil else { return }
        
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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
            }
        }

        return true
    }
}
