
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
        bindOutput()
        bindEvent()
        bindActions()
        bindInput()
        render()
    }
}

private extension ForgotPasswordViewController {

    // MARK: - Navigation
    func setupNavigation() {
        title = "Forgot password"
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Output Binding
    func bindOutput() {
        viewModel.onOutputChanged = { [weak self] in
            guard let self else { return }
            self.render()
        }
    }

    // MARK: - Event Binding
    func bindEvent() {
        viewModel.onEvent = { [weak self] event in
            guard let self else { return }

            switch event {
            case .showError(let message):
                showErrorAlert(message)

            case .showSuccess(let message):
                showSuccessAlert(message)

            case .pop:
                navigationController?.popViewController(animated: true)
            }
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

    // MARK: - Input Binding
    func bindInput() {
        rootView.emailInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updateEmail(text))
            }
        }
    }

    // MARK: - Render
    func render() {
        let output = viewModel.getCurrentOutput()
        rootView.emailInputView.updateError(output.emailErrorMessage)
        rootView.SendEmailButton.isEnabled = output.isSendButtonEnabled
    }

    // MARK: - Actions
    @objc
    func didTapSendEmail() {
        Task {
            await viewModel.action(input: .tapSendVerificationMail)
        }
    }

    // MARK: - Alert
    func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default))

        present(alert, animated: true)
    }

    func showSuccessAlert(_ message: String) {
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
