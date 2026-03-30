//
//   ItemAddTextFieldCardView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//
import UIKit
import SnapKit

final class ItemAddTextFieldCardView: UIView {

    enum Style {
        case single
        case double
    }

    // MARK: - UI
    private let cardView = UIView()
    private let stackView = UIStackView()
    private let dividerView = UIView()

    let firstTextField = UITextField()
    let secondTextField = UITextField()

    // MARK: - Properties
    private let style: Style

    // MARK: - Init
    init(
        style: Style,
        firstPlaceholder: String,
        secondPlaceholder: String? = nil
    ) {
        self.style = style
        super.init(frame: .zero)

        setupUI()
        setupLayout()
        configure(
            firstPlaceholder: firstPlaceholder,
            secondPlaceholder: secondPlaceholder
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    var firstText: String? {
        firstTextField.text
    }

    var secondText: String? {
        secondTextField.text
    }

    func setFirstKeyboardType(_ type: UIKeyboardType) {
        firstTextField.keyboardType = type
    }

    func setSecondKeyboardType(_ type: UIKeyboardType) {
        secondTextField.keyboardType = type
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill

        dividerView.backgroundColor = .systemGray5

        setupTextField(firstTextField)
        setupTextField(secondTextField)

        addSubview(cardView)
        cardView.addSubview(stackView)

        stackView.addArrangedSubview(firstTextField)

        if style == .double {
            stackView.addArrangedSubview(dividerView)
            stackView.addArrangedSubview(secondTextField)
        }
    }

    private func setupTextField(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = Fonts.body
        textField.textColor = Colors.Text.main
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.returnKeyType = .done
    }

    private func setupLayout() {
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        firstTextField.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }

        if style == .double {
            dividerView.snp.makeConstraints { make in
                make.height.equalTo(1)
            }

            secondTextField.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(44)
            }
        }

        // Ensure proper vertical padding inside card
        stackView.setCustomSpacing(8, after: firstTextField)
    }

    private func configure(
        firstPlaceholder: String,
        secondPlaceholder: String?
    ) {
        firstTextField.attributedPlaceholder = NSAttributedString(
            string: firstPlaceholder,
            attributes: [
                .foregroundColor: Colors.Text.additionalInfo
            ]
        )

        if style == .double {
            secondTextField.attributedPlaceholder = NSAttributedString(
                string: secondPlaceholder ?? "",
                attributes: [
                    .foregroundColor: Colors.Text.additionalInfo
                ]
            )
        }
    }
}
