//
//  EmailSignIn.swift
//  Gustav
//
//  Created by kaeun on 3/5/26.
//

import UIKit
import SnapKit

class EmailSignUpEditView: UIView {
    
    // MARK: - StackView
    let emailInputView = AuthInputFieldView(kind: .email)
    let passwordInputView = AuthInputFieldView(kind: .password)
    let repeatPasswordInputView = AuthInputFieldView(kind: .repeatPassword)
    
    
    private let contentStack = UIStackView()
    
    // 이메일 입력
    var emailText: String {
        emailInputView.text
    }

    // 비밀번호 입력
    var passwordText: String {
        passwordInputView.text
    }
    
    var repeatPasswordText: String {
        repeatPasswordInputView.text
    }
    
    // UITextField 접근
    var emailTextField: UITextField { emailInputView.textField }
    var passwordTextField: UITextField { passwordInputView.textField }
    var repeatPasswordTextField: UITextField { repeatPasswordInputView.textField }
    

    
    
    // MARK: - Init
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


private extension EmailSignUpEditView {
    func setupUI() {
        backgroundColor = .clear

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 14

        addSubview(contentStack)

        contentStack.addArrangedSubview(emailInputView)
        contentStack.addArrangedSubview(passwordInputView)
        contentStack.addArrangedSubview(repeatPasswordInputView)
    }

    func setupLayout() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension EmailSignUpEditView {
    func updateEmailError(_ message: String?) {
        emailInputView.updateError(message)
    }

    func updatePasswordError(_ message: String?) {
        passwordInputView.updateError(message)
    }

    func updateRepeatPasswordError(_ message: String?) {
        repeatPasswordInputView.updateError(message)
    }
}
