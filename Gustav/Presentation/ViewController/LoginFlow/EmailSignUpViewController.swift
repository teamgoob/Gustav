//
//  EmailSignUpViewController.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit

// 이메일 회원가입 화면을 담당하는 ViewController
// 역할:
// 1. View 구성 연결
// 2. 사용자 입력을 ViewModel로 전달
// 3. ViewModel의 상태(Output)를 받아 UI 렌더링
final class EmailSignUpViewController: UIViewController {

    // ViewController의 rootView
    // UIView 대신 커스텀 View 사용
    private let rootView = EmailSignUpView()

    // MVVM에서 사용하는 ViewModel
    private let viewModel: EmailSignUpViewModel

    // ViewModel 주입 (DI)
    init(viewModel: EmailSignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // storyboard 사용 금지
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // rootView를 ViewController의 view로 설정
    override func loadView() {
        view = rootView
    }

    // ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation() // 네비게이션 설정
        bindOutput()
        bindEvent()      // ViewModel 이벤트 바인딩
        bindActions()     // 버튼 이벤트 연결
        bindInput()       // 텍스트 입력 이벤트 연결
        bindPolicy()      // 약관 체크 이벤트 연결
        bindDelegate()    // textField delegate 설정
        setupGesture()
        render()          // 초기 UI 렌더링
    }
}

private extension EmailSignUpViewController {

    // 네비게이션 바 설정
    func setupNavigation() {
        title = "Create an account"
        navigationItem.largeTitleDisplayMode = .never
    }

    
    // ViewModel output 변경 감지 → 자동 render
    func bindOutput() {
        viewModel.onOutputChanged = { [weak self] in
            guard let self else { return }
            self.render()
        }
    }
    
    // ViewModel event 수신 → Alert / 화면 이동 처리
    func bindEvent() {
        viewModel.onEvent = { [weak self] event in
            guard let self else { return }

            switch event {
            case .showError(let message):
                showErrorAlert(message)

            case .showSuccess(let message):
                showSuccessAlert(message)

            case .showTerms:
                break

            case .showPrivacy:
                break

            case .pop:
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // 버튼 이벤트 바인딩
    func bindActions() {

        // 회원가입 버튼 클릭
        rootView.formView.signUpButton.addTarget(
            self,
            action: #selector(didTapSignUp),
            for: .touchUpInside
        )

        // 약관 보기 버튼
        rootView.formView.policyAgreementView.termsLookButton.addTarget(
            self,
            action: #selector(didTapTermsLook),
            for: .touchUpInside
        )

        // 개인정보 보기 버튼
        rootView.formView.policyAgreementView.privacyLookButton.addTarget(
            self,
            action: #selector(didTapPrivacyLook),
            for: .touchUpInside
        )
    }

    // 텍스트 입력 이벤트 바인딩
    func bindInput() {

        // 이메일 입력 변경
        rootView.formView.editView.emailInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            // ViewModel에 input 전달
            Task {
                await self.viewModel.action(input: .updateEmail(text))            }
        }

        // 비밀번호 입력 변경
        rootView.formView.editView.passwordInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updatePassword(text))
            }
        }

        // 비밀번호 재입력 변경
        rootView.formView.editView.repeatPasswordInputView.onTextChanged = { [weak self] text in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updateRepeatPassword(text))
            }
        }
    }

    // 약관 동의 체크 이벤트 바인딩
    func bindPolicy() {

        // 이용약관 체크
        rootView.formView.policyAgreementView.onToggleTerms = { [weak self] isChecked in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updateTermsAgreement(isChecked))
            }
        }

        // 개인정보 체크
        rootView.formView.policyAgreementView.onTogglePrivacy = { [weak self] isChecked in
            guard let self else { return }

            Task {
                await self.viewModel.action(input: .updatePrivacyAgreement(isChecked))
            }
        }
    }

    // UITextFieldDelegate 연결
    func bindDelegate() {
        rootView.formView.editView.emailTextField.delegate = self
        rootView.formView.editView.passwordTextField.delegate = self
        rootView.formView.editView.repeatPasswordTextField.delegate = self
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

    // ViewModel의 상태(Output)를 UI에 반영
    func render() {

        // 현재 ViewModel 상태 가져오기
        let output = viewModel.getCurrentOutput()

        // 각 입력 필드 에러 메시지 표시
        rootView.updateEmailError(output.emailErrorMessage)
        rootView.updatePasswordError(output.passwordErrorMessage)
        rootView.updateRepeatPasswordError(output.repeatPasswordErrorMessage)

        // 회원가입 버튼 상태 업데이트
        rootView.updateSignUpButton(
            isEnabled: output.isSignUpButtonEnabled,
            isLoading: output.isLoading
        )
    }

    // 회원가입 버튼 클릭
    @objc func didTapSignUp() {
        Task {
            await viewModel.action(input: .tapSignUp)
        }
    }

    // 이용약관 보기 클릭
    @objc func didTapTermsLook() {
        Task {
            await viewModel.action(input: .tapTermsLook)
        }
    }

    // 개인정보 보기 클릭
    @objc func didTapPrivacyLook() {
        Task {
            await viewModel.action(input: .tapPrivacyLook)
        }
    }

    // 에러 Alert 표시
    func showErrorAlert(_ message: String) {

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default))

        present(alert, animated: true)
    }

    // 성공 Alert 표시
    func showSuccessAlert(_ message: String) {

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        // 확인 누르면 뒤로 이동
        alert.addAction(UIAlertAction(
            title: "확인",
            style: .default
        ) { [weak self] _ in

            guard let self else { return }

            Task {
                await self.viewModel.action(input: .tapBack)
            }
        })

        present(alert, animated: true)
    }
}

// UITextField return 키 동작 처리
extension EmailSignUpViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        let emailField = rootView.formView.editView.emailTextField
        let passwordField = rootView.formView.editView.passwordTextField
        let repeatPasswordField = rootView.formView.editView.repeatPasswordTextField

        // 이메일 -> 비밀번호 이동
        if textField == emailField {

            passwordField.becomeFirstResponder()

        }
        // 비밀번호 -> 재입력 이동
        else if textField == passwordField {

            repeatPasswordField.becomeFirstResponder()

        }
        // 마지막 입력이면 회원가입 실행
        else {

            textField.resignFirstResponder()

            Task {
                await viewModel.action(input: .tapSignUp)
            }
        }

        return true
    }
}
