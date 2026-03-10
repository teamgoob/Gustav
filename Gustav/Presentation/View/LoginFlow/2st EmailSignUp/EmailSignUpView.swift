//
//  EmailSignUpView.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit
import SnapKit

final class EmailSignUpView: UIView {

    // MARK: - UI
    private let cardView = UIView()
    private let contentStack = UIStackView()

    // Title
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Sign up with E-mail"
        lb.font = Fonts.largeTitle
        lb.textAlignment = .center
        lb.textColor = .label
        lb.numberOfLines = 0
        return lb
    }()

    let formView = EmailSignUpFormView()

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

// MARK: - Setup
private extension EmailSignUpView {
    func setupUI() {
        backgroundColor = UIColor.systemGray6

        // 카드 스타일
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true

        // 카드 내부 패딩
        cardView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // 카드 내부 스택
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 36

        addSubview(cardView)
        cardView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(formView)
    }

    func setupLayout() {
        // 작은 화면에서도 카드 깨짐 방지
        cardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(22)
            make.centerY.equalToSuperview().offset(20)

            make.height.equalToSuperview().multipliedBy(0.85)

            make.top.greaterThanOrEqualTo(safeAreaLayoutGuide).inset(18)
            make.bottom.lessThanOrEqualTo(safeAreaLayoutGuide).inset(18)
        }

        // 스택은 카드 margin 기준으로 꽉 채움
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(cardView.layoutMarginsGuide)
//            make.centerY.equalTo(cardView)
        }
    }
}

// MARK: - Input Value
extension EmailSignUpView {
    var emailText: String {
        formView.emailText
    }

    var passwordText: String {
        formView.passwordText
    }

    var repeatPasswordText: String {
        formView.repeatPasswordText
    }

    var isTermsAgreed: Bool {
        formView.isTermsAgreed
    }

    var isPrivacyAgreed: Bool {
        formView.isPrivacyAgreed
    }
}

// MARK: - Error / Button Update
extension EmailSignUpView {
    func updateEmailError(_ message: String?) {
        formView.updateEmailError(message)
    }

    func updatePasswordError(_ message: String?) {
        formView.updatePasswordError(message)
    }

    func updateRepeatPasswordError(_ message: String?) {
        formView.updateRepeatPasswordError(message)
    }

    func updateSignUpButton(isEnabled: Bool, isLoading: Bool) {
        formView.updateSignUpButton(isEnabled: isEnabled, isLoading: isLoading)
    }
}
