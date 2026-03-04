//
//  EmailFieldView.swift
//  Gustav
//
//  Created by kaeun on 3/4/26.
//

import UIKit
import SnapKit

class EmailPasswordView: UIView {
    

    
    
    // 이메일 아이콘 + 텍스트 담는 컨테이너
    private let emailContainer = UIView()
    
    // 이메일 아이콘
    private let emailIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "envelope.fill")
        iv.tintColor = Colors.Theme.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // 이메일 텍스트
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E - mail"
        
        // 키보드
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        
        // 키체인
        tf.textContentType = .emailAddress

        // 자동 수정 방지
        tf.autocapitalizationType = .none // 대문자 비활성화
        tf.autocorrectionType = .no // 자동 맞춤법 수정 비활성화
        tf.spellCheckingType = .no
        
        // 입력 UX
        tf.clearButtonMode = .whileEditing // 입력 중일 때 오른쪽에 x 버튼
        
        // 스타일
        tf.font = Fonts.body
        tf.textColor = Colors.Text.additionalInfo
        return tf
    }()
    
    
    // 비밀번호 아이콘 + 텍스트 담는 컨테이터
    private let passwordContainer = UIView()
    
    // 비밀번호 아이콘
    private let passwordIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.fill")
        iv.tintColor = Colors.Theme.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // 비밀번호 가리기/보기 토글
    let passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    
    // 비밀번호 입력창
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        
        // 키보드
        tf.returnKeyType = .done // 리턴키 : 완료
        
        // 비밀번호 숨김
        tf.isSecureTextEntry = true
        
        // Keychain 자동완성
        tf.textContentType = .password

        // 자동 수정 방지
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        
        
        // 스타일
        tf.font = Fonts.body
        tf.textColor = Colors.Text.additionalInfo
        
        return tf
    }()
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
        setupActions()
    }

    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        // 컨테이너 스타일(원하시면 값 조절)
        [emailContainer, passwordContainer].forEach {
            $0.backgroundColor = Colors.Theme.textBackground
            $0.layer.cornerRadius = 14
            $0.layer.masksToBounds = true
        }

        addSubview(emailContainer)
        addSubview(passwordContainer)

        emailContainer.addSubview(emailIconView)
        emailContainer.addSubview(emailTextField)

        passwordContainer.addSubview(passwordIconView)
        passwordContainer.addSubview(passwordTextField)

        // 토글을 텍스트필드 안에 넣기
        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always
    }

    // 배치
    private func setupLayout() {
        // 컨테이너 배치
        emailContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }

        passwordContainer.snp.makeConstraints { make in
            make.top.equalTo(emailContainer.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
            make.bottom.equalToSuperview()
        }

        // Email 내부
        emailIconView.snp.makeConstraints { make in
            make.centerY.equalTo(emailContainer)
            make.leading.equalTo(emailContainer).offset(16)
            make.width.height.equalTo(30)
        }

        emailTextField.snp.makeConstraints { make in
            make.centerY.equalTo(emailContainer)
            make.leading.equalTo(emailIconView.snp.trailing).offset(12)
            make.trailing.equalTo(emailContainer).inset(12)
        }

        // Password 내부
        passwordIconView.snp.makeConstraints { make in
            make.centerY.equalTo(passwordContainer)
            make.leading.equalTo(passwordContainer).offset(16)
            make.width.height.equalTo(30)
        }

        passwordTextField.snp.makeConstraints { make in
            make.centerY.equalTo(passwordContainer)
            make.leading.equalTo(passwordIconView.snp.trailing).offset(12)
            make.trailing.equalTo(passwordContainer).inset(12)
        }
    }

    // togglePassword 실행 함수
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
    }

    // MARK: - Action
    
    // 비밀번호 보기/가리기 실행 함수
    @objc private func togglePassword() {
        let wasFirstResponder = passwordTextField.isFirstResponder

        passwordTextField.isSecureTextEntry.toggle()

        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)

        // 커서 튐 방지
        if wasFirstResponder {
            passwordTextField.becomeFirstResponder()
        }
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
// MARK: - preView
#if DEBUG
import SwiftUI

struct EmailPasswordViewPreview: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        EmailPasswordView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    EmailPasswordViewPreview()
}
#endif
