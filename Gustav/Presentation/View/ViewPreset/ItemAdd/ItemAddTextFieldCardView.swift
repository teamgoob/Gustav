//
//   ItemAddTextFieldCardView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//
import UIKit
import SnapKit

final class ItemAddTextFieldCardView: UIView {

    // MARK: - Style
    enum Style {
        case single
        case double
    }

    // MARK: - UI
    private let cardView = UIView()
    private let stackView = UIStackView()
    private let dividerView = UIView()

    private let firstTextField = UITextField()
    private let secondTextField = UITextField()

    // MARK: - Properties
    private let style: Style

    // 텍스트 변경 이벤트를 외부(ViewController / ViewModel)로 전달하는 클로저
    var onFirstTextChanged: ((String) -> Void)?
    var onSecondTextChanged: ((String) -> Void)?

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
    // 첫 번째 텍스트필드의 현재 텍스트에 접근하거나 값을 설정합니다.
    var firstText: String? {
        get { firstTextField.text }
        set { firstTextField.text = newValue }
    }

    // 두 번째 텍스트필드의 현재 텍스트에 접근하거나 값을 설정합니다.
    var secondText: String? {
        get { secondTextField.text }
        set { secondTextField.text = newValue }
    }

    // 첫 번째 텍스트필드의 텍스트를 외부에서 설정합니다.
    func setFirstText(_ text: String?) {
        firstTextField.text = text
    }

    // 두 번째 텍스트필드의 텍스트를 외부에서 설정합니다.
    func setSecondText(_ text: String?) {
        secondTextField.text = text
    }

    // 첫 번째 텍스트필드의 return 키 타입을 설정합니다.
    func setFirstReturnKeyType(_ type: UIReturnKeyType) {
        firstTextField.returnKeyType = type
    }

    // 두 번째 텍스트필드의 return 키 타입을 설정합니다.
    func setSecondReturnKeyType(_ type: UIReturnKeyType) {
        secondTextField.returnKeyType = type
    }
    
    // 첫 번째 텍스트필드의 키보드 타입을 설정합니다.
    func setFirstKeyboardType(_ type: UIKeyboardType) {
        firstTextField.keyboardType = type
    }

    // 두 번째 텍스트필드의 키보드 타입을 설정합니다.
    func setSecondKeyboardType(_ type: UIKeyboardType) {
        secondTextField.keyboardType = type
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        // 카드 형태의 흰색 컨테이너 뷰 설정
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true

        // 텍스트필드들을 세로로 배치할 스택뷰 설정
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill

        // 두 개의 텍스트필드 사이를 구분하는 디바이더 색상 설정
        dividerView.backgroundColor = .systemGray5

        // 공통 텍스트필드 스타일 적용
        setupTextField(firstTextField)
        setupTextField(secondTextField)

        firstTextField.delegate = self
        secondTextField.delegate = self

        // 사용자가 입력할 때마다 텍스트 변경 이벤트를 감지
        firstTextField.addTarget(self, action: #selector(didChangeFirstTextField), for: .editingChanged)
        secondTextField.addTarget(self, action: #selector(didChangeSecondTextField), for: .editingChanged)

        addSubview(cardView)
        cardView.addSubview(stackView)

        // 첫 번째 텍스트필드는 항상 표시
        stackView.addArrangedSubview(firstTextField)

        // double 스타일일 때만 디바이더와 두 번째 텍스트필드를 추가
        if style == .double {
            stackView.addArrangedSubview(dividerView)
            stackView.addArrangedSubview(secondTextField)
        }
    }

    // 첫 번째 텍스트필드의 입력값이 바뀌면 외부 클로저로 전달합니다.
    @objc private func didChangeFirstTextField() {
        onFirstTextChanged?(firstTextField.text ?? "")
    }

    // 두 번째 텍스트필드의 입력값이 바뀌면 외부 클로저로 전달합니다.
    @objc private func didChangeSecondTextField() {
        onSecondTextChanged?(secondTextField.text ?? "")
    }
    
    // 두 텍스트필드에 공통으로 적용할 기본 스타일을 설정합니다.
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
        // 카드 뷰가 현재 뷰 전체를 채우도록 설정
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 스택뷰가 카드 뷰 안쪽 여백 16을 가지고 배치되도록 설정
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        // 첫 번째 텍스트필드의 최소 터치 영역 높이 확보
        firstTextField.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }

        if style == .double {
            // 디바이더를 1pt 높이로 설정
            dividerView.snp.makeConstraints { make in
                make.height.equalTo(1)
            }

            // 두 번째 텍스트필드의 최소 터치 영역 높이 확보
            secondTextField.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(44)
            }
        }

        // 첫 번째 텍스트필드 아래 간격을 조금 더 좁게 조정
        stackView.setCustomSpacing(8, after: firstTextField)
    }

    private func configure(
        firstPlaceholder: String,
        secondPlaceholder: String?
    ) {
        // 첫 번째 텍스트필드 placeholder 스타일 적용
        firstTextField.attributedPlaceholder = NSAttributedString(
            string: firstPlaceholder,
            attributes: [
                .foregroundColor: Colors.Text.additionalInfo
            ]
        )

        // double 스타일일 때만 두 번째 텍스트필드 placeholder를 설정
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

// MARK: - UITextFieldDelegate
extension ItemAddTextFieldCardView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // double 스타일일 때만 첫 번째 텍스트필드에서 두 번째로 포커스를 이동합니다.
        if style == .double, textField == firstTextField {
            secondTextField.becomeFirstResponder()
        } else {
            // single 스타일이거나 마지막 필드면 키보드를 내립니다.
            textField.resignFirstResponder()
        }
        return true
    }
}
