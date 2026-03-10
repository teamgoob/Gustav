//
//  RowSetView.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import UIKit
import SnapKit

final class PolicyAgreementView: UIView {

    // MARK: - Terms
    private let termsCheckButton = UIButton(type: .system)
    private let termsTitleLabel = UILabel()
    let termsLookButton = UIButton(type: .system)

    // MARK: - Privacy
    private let privacyCheckButton = UIButton(type: .system)
    private let privacyTitleLabel = UILabel()
    let privacyLookButton = UIButton(type: .system)

    // MARK: - Stack
    private let contentStack = UIStackView()
    private let termsRowStack = UIStackView()
    private let privacyRowStack = UIStackView()

    // MARK: - State
    private(set) var isTermsAgreed: Bool = false
    private(set) var isPrivacyAgreed: Bool = false

    // MARK: - Action
    var onToggleTerms: ((Bool) -> Void)?
    var onTogglePrivacy: ((Bool) -> Void)?
    var onTapTermsLook: (() -> Void)?
    var onTapPrivacyLook: (() -> Void)?

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
}

// MARK: - Setup
private extension PolicyAgreementView {
    func setupUI() {
        backgroundColor = .clear

        setupCheckButtons()
        setupLabels()
        setupLookButtons()
        setupStacks()
    }

    func setupCheckButtons() {
        [termsCheckButton, privacyCheckButton].forEach {
            $0.setImage(UIImage(systemName: "circle"), for: .normal)
            $0.tintColor = Colors.Theme.primary
        }
    }

    func setupLabels() {
        termsTitleLabel.text = "I agree to the terms of policy."
        privacyTitleLabel.text = "I agree to the privacy policy."

        [termsTitleLabel, privacyTitleLabel].forEach {
            $0.font = Fonts.body
            $0.textColor = Colors.Text.main
            $0.numberOfLines = 1
        }
    }

    func setupLookButtons() {
        let title = "Look"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.Theme.primary,
            .font: Fonts.body,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        let attributedTitle = NSAttributedString(string: title, attributes: attributes)

        termsLookButton.setAttributedTitle(attributedTitle, for: .normal)
        privacyLookButton.setAttributedTitle(attributedTitle, for: .normal)
    }

    func setupStacks() {
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 24

        [termsRowStack, privacyRowStack].forEach {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 8
        }

        addSubview(contentStack)

        termsRowStack.addArrangedSubview(termsCheckButton)
        termsRowStack.addArrangedSubview(termsTitleLabel)
        termsRowStack.addArrangedSubview(UIView())
        termsRowStack.addArrangedSubview(termsLookButton)

        privacyRowStack.addArrangedSubview(privacyCheckButton)
        privacyRowStack.addArrangedSubview(privacyTitleLabel)
        privacyRowStack.addArrangedSubview(UIView())
        privacyRowStack.addArrangedSubview(privacyLookButton)

        contentStack.addArrangedSubview(termsRowStack)
        contentStack.addArrangedSubview(privacyRowStack)
    }

    func setupLayout() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        [termsCheckButton, privacyCheckButton].forEach {
            $0.snp.makeConstraints { make in
                make.size.equalTo(20)
            }
        }
    }

    func setupActions() {
        termsCheckButton.addTarget(self, action: #selector(toggleTerms), for: .touchUpInside)
        privacyCheckButton.addTarget(self, action: #selector(togglePrivacy), for: .touchUpInside)

        termsLookButton.addTarget(self, action: #selector(didTapTermsLook), for: .touchUpInside)
        privacyLookButton.addTarget(self, action: #selector(didTapPrivacyLook), for: .touchUpInside)
    }
}

// MARK: - Action
private extension PolicyAgreementView {
    @objc func toggleTerms() {
        isTermsAgreed.toggle()
        updateCheckButtonImage(button: termsCheckButton, isChecked: isTermsAgreed)
        onToggleTerms?(isTermsAgreed)
    }

    @objc func togglePrivacy() {
        isPrivacyAgreed.toggle()
        updateCheckButtonImage(button: privacyCheckButton, isChecked: isPrivacyAgreed)
        onTogglePrivacy?(isPrivacyAgreed)
    }

    @objc func didTapTermsLook() {
        onTapTermsLook?()
    }

    @objc func didTapPrivacyLook() {
        onTapPrivacyLook?()
    }

    func updateCheckButtonImage(button: UIButton, isChecked: Bool) {
        let imageName = isChecked ? "checkmark.circle.fill" : "circle"
        button.setImage(UIImage(systemName: imageName), for: .normal)

        if #available(iOS 17.0, *) {
            button.imageView?.addSymbolEffect(.bounce, options: .nonRepeating)
        }
    }
}
