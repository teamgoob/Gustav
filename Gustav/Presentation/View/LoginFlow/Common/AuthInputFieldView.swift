//
//  AuthInputFieldView.swift
//  Gustav
//
//  Created by kaeun on 3/10/26.
//

import UIKit
import SnapKit

final class AuthInputFieldView: UIView {

    // 입력 필드 종류
    // 이메일 / 비밀번호 / 비밀번호 재입력
    // 종류에 따라 placeholder, 아이콘, secure 여부가 달라짐
    enum Kind {
        case email
        case password
        case repeatPassword
    }

    // 입력칸 배경 컨테이너
    // 둥근 배경 + 아이콘 + 텍스트필드를 담는 역할
    private let containerView = UIView()

    // 왼쪽 아이콘 (email / password)
    private let iconImageView = UIImageView()

    // 입력 오류 표시 라벨
    // 예: 이메일 형식 오류, 비밀번호 길이 오류 등
    private let errorLabel = UILabel()
    
    
    // 실제 텍스트 입력 필드
    // 외부(ViewController)에서도 접근할 수 있도록 public
    let textField = UITextField()

    // 비밀번호 보기/숨기기 토글 버튼
    // password / repeatPassword에서만 사용
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 눈 토클 사이즈 줄이기
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let image = UIImage(systemName: "eye.slash", withConfiguration: config)

        button.setImage(image, for: .normal)
        button.tintColor = Colors.Text.additionalInfo
        button.isHidden = true
        return button
    }()

    private let kind: Kind

    // 텍스트가 변경될 때 외부(ViewController / ViewModel)로 전달하는 콜백
    var onTextChanged: ((String) -> Void)?

    
    // 현재 입력된 텍스트 반환
    // ViewController에서 쉽게 값 읽기 위해 사용
    var text: String {
        textField.text ?? ""
    }

    // 생성 시 입력 필드 종류를 전달받음
    init(kind: Kind) {
        self.kind = kind
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        setupActions()
        configure(kind: kind)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setup UI
private extension AuthInputFieldView {
    func setupUI() {
        backgroundColor = .clear


        // 입력칸 배경 스타일
        containerView.backgroundColor = Colors.Theme.textBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.masksToBounds = true

        // 아이콘 비율 유지
        iconImageView.contentMode = .scaleAspectFit

        // 텍스트 필드 기본 스타일
        textField.font = Fonts.body
        textField.textColor = Colors.Text.additionalInfo

        // 자동 입력 수정 방지
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no

        // 에러 라벨 스타일
        errorLabel.textColor = Colors.Text.error
        errorLabel.font = Fonts.caption
        errorLabel.numberOfLines = 0

        // 기본은 숨김
        errorLabel.isHidden = true

        // View 계층 구성
        addSubview(containerView)
        addSubview(errorLabel)

        containerView.addSubview(iconImageView)
        containerView.addSubview(textField)
    }

    func setupLayout() {
        // 입력 컨테이너 위치
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }

        // 왼쪽 아이콘 위치
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.leading.equalTo(containerView).offset(16)
            make.size.equalTo(30)
        }

        // 텍스트 필드 위치
        textField.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(containerView).inset(12)
        }

        // 에러 메시지 위치
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
        }
    }

    func setupActions() {

        // 텍스트 변경 감지
        textField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )

        // 비밀번호 토글 버튼
        toggleButton.addTarget(
            self,
            action: #selector(toggleSecureEntry),
            for: .touchUpInside
        )
    }

    func configure(kind: Kind) {

        switch kind {

        // 이메일 입력칸
        case .email:

            iconImageView.image = Icons.email
            iconImageView.tintColor = Colors.Theme.primary

            textField.placeholder = "E - mail"
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .next

            // iOS Keychain 자동완성
            textField.textContentType = .emailAddress

            // 입력 중 clear 버튼 표시
            textField.clearButtonMode = .whileEditing

        // 비밀번호 입력칸
        case .password:

            iconImageView.image = Icons.password
            iconImageView.tintColor = Colors.Theme.primary

            textField.placeholder = "Password"
            textField.returnKeyType = .next
            textField.textContentType = .password

            // 비밀번호 숨김
            textField.isSecureTextEntry = true

            // eye 버튼 추가
            textField.rightView = toggleButton
            textField.rightViewMode = .always
            toggleButton.isHidden = false

        // 비밀번호 재입력
        case .repeatPassword:

            iconImageView.image = Icons.password
            iconImageView.tintColor = Colors.Theme.primary

            textField.placeholder = "Repeat Password"
            textField.returnKeyType = .done
            textField.textContentType = .password

            textField.isSecureTextEntry = true

            textField.rightView = toggleButton
            textField.rightViewMode = .always
            toggleButton.isHidden = false
        }
    }
}
// MARK: - Action
private extension AuthInputFieldView {

    // 텍스트 변경 시 외부로 전달
    @objc func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }

    // 비밀번호 보기/숨기기 토글
    @objc func toggleSecureEntry() {

        // 현재 포커스 상태 저장
        let wasFirstResponder = textField.isFirstResponder

        // secure 상태 반전
        textField.isSecureTextEntry.toggle()

        // 아이콘 변경
        
        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        toggleButton.setImage(image, for: .normal)

        // 커서 튐 방지
        if wasFirstResponder {
            textField.becomeFirstResponder()
        }
    }
}

extension AuthInputFieldView {

    // 입력 오류 메시지 표시
    func updateError(_ message: String?) {

        // 메시지 업데이트
        errorLabel.text = message

        // 메시지가 없으면 숨김
        errorLabel.isHidden = (message == nil)
    }
}
