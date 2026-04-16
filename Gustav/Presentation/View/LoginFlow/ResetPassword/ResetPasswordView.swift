//
//  ResetPasswordView.swift
//  Gustav
//
//  Created by Kaeun on 2026/4/15.
//

import UIKit
import SnapKit

final class ResetPasswordView: UIView {

    private let cardView = UIView()
    private let scrollView = UIScrollView()
    private let headerStack = UIStackView()
    private let formStack = UIStackView()

    let passwordInputView = AuthInputFieldView(kind: .password)
    let repeatPasswordInputView = AuthInputFieldView(kind: .repeatPassword)

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.headline
        button.backgroundColor = Colors.Theme.primary
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset password"
        label.font = Fonts.largeTitle
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Enter your new password below.
        Use at least 8 characters with letters and digits.
        """
        label.font = Fonts.body
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    var passwordTextField: UITextField { passwordInputView.textField }
    var repeatPasswordTextField: UITextField { repeatPasswordInputView.textField }

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

private extension ResetPasswordView {
    func setupUI() {
        backgroundColor = Colors.Theme.mainBackground

        cardView.backgroundColor = Colors.Theme.cardBackground
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true
        cardView.layoutMargins = UIEdgeInsets(top: 100, left: 16, bottom: 16, right: 16)

        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false

        headerStack.axis = .vertical
        headerStack.alignment = .fill
        headerStack.distribution = .fill
        headerStack.spacing = 24

        formStack.axis = .vertical
        formStack.alignment = .fill
        formStack.distribution = .fill
        formStack.spacing = 14

        addSubview(cardView)
        cardView.addSubview(scrollView)
        cardView.addSubview(formStack)
        scrollView.addSubview(headerStack)

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(descriptionLabel)

        formStack.addArrangedSubview(passwordInputView)
        formStack.addArrangedSubview(repeatPasswordInputView)
        formStack.addArrangedSubview(submitButton)
    }

    func setupLayout() {
        cardView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(cardView.layoutMarginsGuide)
            make.bottom.equalTo(formStack.snp.top).offset(-24)
        }

        headerStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        formStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(cardView.layoutMarginsGuide)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-60)
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}

extension ResetPasswordView {
    func updatePasswordError(_ message: String?) {
        passwordInputView.updateError(message)
    }

    func updateRepeatPasswordError(_ message: String?) {
        repeatPasswordInputView.updateError(message)
    }

    func updateSubmitButton(isEnabled: Bool, isLoading: Bool) {
        submitButton.isEnabled = isEnabled
        submitButton.alpha = isEnabled ? 1.0 : 0.5

        let title = isLoading ? "Updating..." : "Update password"
        submitButton.setTitle(title, for: .normal)
    }
}
