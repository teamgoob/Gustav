//
//  LoginFormView.swift
//  Gustav
//
//  Created by kaeun on 3/4/26.
//

// 로그인 UI 묶음
import UIKit
import SnapKit
import AuthenticationServices

final class LoginFormView: UIView {
    
    // MARK: - UI 요소
    // 이메일 + 비밀번호 입력창
    let emailPasswordView = EmailPasswordView()
    
    // 로그인 버튼
    let signInButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign In", for: .normal)
        b.titleLabel?.font = Fonts.headline
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = Colors.Theme.primary
        b.layer.cornerRadius = 14
        b.layer.masksToBounds = true
        return b
    }()
    
    // 비밀번호 찾기
    let forgotPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Forgot password?", for: .normal)
        b.titleLabel?.font = Fonts.body
        b.setTitleColor(.label, for: .normal)
        
        return b
    }()
    
    // 선 디바이더
    private let dividerLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.label.withAlphaComponent(0.25)
        return v
    }()
    
    // 이메일로 회원 가입
    let createAccountButton: UIButton = {
        let b = UIButton(type: .system)
        
        // 이메일 아이콘 + Create an account
        b.setTitle(" Create an account", for: .normal)
        b.setImage(UIImage(systemName: "envelope.fill"), for: .normal)
        
        // 아이콘, 텍스트 색상
        b.tintColor = Colors.Theme.primary
        b.setTitleColor(Colors.Theme.primary, for: .normal)
        
        // 버튼 폰트 크기
        b.titleLabel?.font = Fonts.headline
        
        b.backgroundColor = .clear
        b.layer.cornerRadius = 14
        b.layer.borderWidth = 1.5 // 선 굵기
        b.layer.borderColor = Colors.Theme.primary.cgColor
        b.layer.masksToBounds = true
        
        return b
    }()
    
    // 애플로 로그인
    let appleLoginButton: UIButton = {
        let b = UIButton(type: .system)
        
        // 아이콘 + 텍스트
        b.setTitle(" Sign in with Apple", for: .normal)
        b.setImage(UIImage(systemName: "applelogo"), for: .normal)
        
        // 색상 (Apple 가이드)
        b.backgroundColor = .black
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        
        // 폰트 
        b.titleLabel?.font = Fonts.headline
        
        // 모서리
        b.layer.cornerRadius = 14
        b.layer.masksToBounds = true


        return b
    }()
    
    private let contentStack = UIStackView()

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
    // MARK: - SetUp UI
    private func setupUI() {
        backgroundColor = .clear

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 16

        addSubview(contentStack)

        // 스택 순서
        contentStack.addArrangedSubview(emailPasswordView)
        contentStack.setCustomSpacing(24, after: emailPasswordView)

        contentStack.addArrangedSubview(signInButton)
        contentStack.addArrangedSubview(forgotPasswordButton)
        contentStack.setCustomSpacing(16, after: forgotPasswordButton)

        contentStack.addArrangedSubview(dividerLine)
        contentStack.setCustomSpacing(16, after: dividerLine)

        contentStack.addArrangedSubview(createAccountButton)
        contentStack.addArrangedSubview(appleLoginButton)

        // 높이 고정 (UI 안정)
        signInButton.snp.makeConstraints { $0.height.equalTo(56) }
        createAccountButton.snp.makeConstraints { $0.height.equalTo(56) }
        appleLoginButton.snp.makeConstraints { $0.height.equalTo(56) }
        dividerLine.snp.makeConstraints { $0.height.equalTo(1) }

        // forgot 버튼 중앙정렬
        forgotPasswordButton.contentHorizontalAlignment = .center
    }
    
    // MARK: - SetUp Layout
    private func setupLayout() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(didTapForgot), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(didTapApple), for: .touchUpInside)
    }
    
    var onTapSignIn: (() -> Void)?
    var onTapForgotPassword: (() -> Void)?
    var onTapCreateAccount: (() -> Void)?
    var onTapAppleLogin: (() -> Void)?

    @objc private func didTapSignIn() { onTapSignIn?() }
    @objc private func didTapForgot() { onTapForgotPassword?() }
    @objc private func didTapCreateAccount() { onTapCreateAccount?() }
    @objc private func didTapApple() { onTapAppleLogin?() }

}

extension LoginFormView {
    var emailText: String {
        emailPasswordView.emailText
    }

    var passwordText: String {
        emailPasswordView.passwordText
    }
}
