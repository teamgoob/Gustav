//
//  ResetPasswordViewController.swift
//  Gustav
//
//  Created by Kaeun on 2026/4/15.
//

import UIKit

final class ResetPasswordViewController: UIViewController {

    private let rootView = ResetPasswordView()
    private let viewModel: ResetPasswordViewModel

    init(viewModel: ResetPasswordViewModel) {
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

        setupNavigation()
        setupDelegate()
        bindViewModel()
        bindActions()
        bindInput()
        setupGesture()
        apply(viewModel.getCurrentOutput())
    }
}

private extension ResetPasswordViewController {
    func setupNavigation() {
        title = "Reset password"
        navigationItem.largeTitleDisplayMode = .never
    }

    func setupDelegate() {
        rootView.passwordTextField.delegate = self
        rootView.repeatPasswordTextField.delegate = self
    }

    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }

        viewModel.onEvent = { [weak self] event in
            self?.handleEvent(event)
        }
    }

    func bindActions() {
        rootView.submitButton.addTarget(
            self,
            action: #selector(didTapSubmit),
            for: .touchUpInside
        )
    }

    func bindInput() {
        rootView.passwordInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updatePassword(text))
            }
        }

        rootView.repeatPasswordInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updateRepeatPassword(text))
            }
        }
    }

    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    func didTapSubmit() {
        Task {
            await viewModel.action(input: .tapSubmit)
        }
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }

    func apply(_ output: ResetPasswordViewModel.Output) {
        rootView.updatePasswordError(output.passwordErrorMessage)
        rootView.updateRepeatPasswordError(output.repeatPasswordErrorMessage)
        rootView.updateSubmitButton(
            isEnabled: output.isSubmitButtonEnabled,
            isLoading: output.isLoading
        )
    }

    func handleEvent(_ event: ResetPasswordViewModel.Event) {
        switch event {
        case .showError(let message):
            showErrorAlert(message)
        case .completeReset(let message):
            showSuccessAlert(message)
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }

    func showErrorAlert(_ message: String) {
        guard presentedViewController == nil else { return }

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func showSuccessAlert(_ message: String) {
        guard presentedViewController == nil else { return }

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            NotificationCenter.default.post(name: .login, object: nil)
        })

        present(alert, animated: true)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let passwordField = rootView.passwordTextField
        let repeatPasswordField = rootView.repeatPasswordTextField

        if textField == passwordField {
            repeatPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()

            Task {
                await viewModel.action(input: .tapSubmit)
            }
        }

        return true
    }
}
