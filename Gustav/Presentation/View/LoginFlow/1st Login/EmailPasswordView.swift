//
//  EmailFieldView.swift
//  Gustav
//
//  Created by kaeun on 3/4/26.
//

import UIKit
import SnapKit

class EmailPasswordView: UIView {
    
    let emailInputView = AuthInputFieldView(kind: .email)
    let passwordInputView = AuthInputFieldView(kind: .password)
    
    private let contentStack = UIStackView()
    
    // 이메일 입력
    var emailText: String {
        emailInputView.text
    }

    // 비밀번호 입력
    var passwordText: String {
        passwordInputView.text
    }
    
    
    // UITextField 접근
    var emailTextField: UITextField { emailInputView.textField }
    var passwordTextField: UITextField { passwordInputView.textField }
    
    
    // MARK: - init
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
    }
    

}


private extension EmailPasswordView {
    func setupUI() {
        backgroundColor = .clear

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 1

        addSubview(contentStack)

        contentStack.addArrangedSubview(emailInputView)
        contentStack.addArrangedSubview(passwordInputView)
    }

    func setupLayout() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension EmailPasswordView {
    func updateEmailError(_ message: String?) {
        emailInputView.updateError(message)
    }

    func updatePasswordError(_ message: String?) {
        passwordInputView.updateError(message)
    }
}

/* 뷰컨트롤러 뷰디드로드 안.
 emailTextField.delegate = self
 passwordTextField.delegate = self
 */

/*
extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleLogin()
        }

        return true
    }
}
 */
