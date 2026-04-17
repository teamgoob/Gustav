//
//  EmailSignUpFormView.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit
import SnapKit

final class EmailSignUpFormView: UIView {

 
    // 이메일 / 비밀번호 / 비밀번호 재입력 입력뷰
    let editView = EmailSignUpEditView()

    // Row
    let policyAgreementView = PolicyAgreementView()

    // 회원가입 버튼
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.headline
        button.backgroundColor = Colors.Theme.primary
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        return button
    }()

    // Form 전체를 세로로 배치하는 StackView
    private let contentStack = UIStackView()

    // MARK: - Input Value (외부에서 입력값을 읽기 위한 프로퍼티)

    // 이메일 입력값
    var emailText: String {
        editView.emailText
    }
    // 비밀번호 입력값
    var passwordText: String {
        editView.passwordText
    }
    // 비밀번호 재입력 값
    var repeatPasswordText: String {
        editView.repeatPasswordText
    }
    // 약관 동의 여부
    var isTermsAgreed: Bool {
        policyAgreementView.isTermsAgreed
    }
    // 개인정보 동의 여부
    var isPrivacyAgreed: Bool {
        policyAgreementView.isPrivacyAgreed
    }

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


private extension EmailSignUpFormView {

    // UI 구성
    func setupUI() {
        backgroundColor = .clear

        // StackView 설정
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 40

        addSubview(contentStack)

        // StackView 내부 구성
        contentStack.addArrangedSubview(editView)          // 입력 영역
        contentStack.addArrangedSubview(policyAgreementView)      // 약관 동의

        // 개인정보 동의 아래 간격 추가
        contentStack.setCustomSpacing(80, after: editView)

        // 가입 버튼
        contentStack.addArrangedSubview(signUpButton)
    }

    // Layout 설정
    func setupLayout() {

        // StackView 전체 영역 채우기
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // PolicyAgreementView 높이 고정 (UI 안정)
        policyAgreementView.snp.makeConstraints { make in
            make.height.equalTo(72)
        }

        // 버튼 높이 고정
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}


extension EmailSignUpFormView {

    // MARK: - Error Update

    // 이메일 오류 표시
    func updateEmailError(_ message: String?) {
        editView.updateEmailError(message)
    }

    // 비밀번호 오류 표시
    func updatePasswordError(_ message: String?) {
        editView.updatePasswordError(message)
    }

    // 비밀번호 재입력 오류 표시
    func updateRepeatPasswordError(_ message: String?) {
        editView.updateRepeatPasswordError(message)
    }

    // MARK: - SignUp Button State

    // 회원가입 버튼 상태 업데이트
    func updateSignUpButton(isEnabled: Bool, isLoading: Bool) {

        // 버튼 활성화 / 비활성화
        signUpButton.isEnabled = isEnabled

        // 비활성화 시 투명도 낮춤
        signUpButton.alpha = isEnabled ? 1.0 : 0.5

        // 로딩 상태일 경우 텍스트 변경
        let title = isLoading ? "Loading..." : "Sign Up"
        signUpButton.setTitle(title, for: .normal)
    }
}
