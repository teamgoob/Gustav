
//  Gustav
//
//  Created by kaeun on 3/13/26.
//

import UIKit

// 비밀번호 찾기 화면을 담당하는 ViewController
// 역할:
// 1. View 구성 연결
// 2. 사용자 입력을 ViewModel로 전달
// 3. ViewModel의 상태(Output)를 받아 UI 렌더링
final class ForgotPasswordViewController: UIViewController {

    // rootView
    private let rootView = ForgotPasswordView()

    // ViewModel
    private let viewModel: ForgotPasswordViewModel

    // DI
    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // rootView 연결
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

private extension ForgotPasswordViewController {

    // MARK: - Navigation
    func setupNavigation() {
        title = "Forgot password"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - ViewModel Binding
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        
        viewModel.onEvent = { [weak self] event in
            self?.handleEvent(event)
        }
    }

    // MARK: - Button Actions
    func bindActions() {
        rootView.SendEmailButton.addTarget(
            self,
            action: #selector(didTapSendEmail),
            for: .touchUpInside
        )
    }

    func setupDelegate() {
        rootView.emailInputView.textField.delegate = self
        rootView.emailInputView.textField.returnKeyType = .send
        rootView.emailInputView.textField.enablesReturnKeyAutomatically = true
    }

    // MARK: - Input Binding
    func bindInput() {
        rootView.emailInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updateEmail(text))
            }
        }
    }

    // MARK: - Output Apply
    func apply(_ output: ForgotPasswordViewModel.Output) {
        rootView.emailInputView.updateError(output.emailErrorMessage)
        rootView.SendEmailButton.isEnabled = output.isSendButtonEnabled
    }

    // MARK: - Event Handle
    func handleEvent(_ event: ForgotPasswordViewModel.Event) {
        switch event {
        case .showError(let message):
            showErrorAlert(message)
        case .showSuccess(let message):
            showSuccessAlert(message)
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Actions
    @objc
    func didTapSendEmail() {
        view.endEditing(true)

        Task {
            await viewModel.action(input: .tapSendVerificationMail)
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

    // MARK: - Alert
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

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .tapBack)
            }
        })

        present(alert, animated: true)
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if rootView.SendEmailButton.isEnabled {
            didTapSendEmail()
        }

        return true
    }
}
