//
//  AccountDeletingView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/10.
//

import UIKit
import SnapKit
import SwiftUI

// MARK: - AccountDeletingView
// 회원 탈퇴 화면
final class AccountDeletingView: UIView {
    // MARK: - Container
    // Card View
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Theme.cardBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - UILabel
    // Title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delete Account"
        label.font = Fonts.largeTitle
        label.textAlignment = .left
        label.textColor = Colors.Text.main
        return label
    }()
    
    // Description
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your registered email address for verification."
        label.font = Fonts.accent
        label.textAlignment = .left
        label.textColor = Colors.Text.main
        label.numberOfLines = 0
        return label
    }()
    
    // Caution
    private let cautionLabel: UILabel = {
        let label = UILabel()
        label.text = "This action cannot be undone."
        label.font = Fonts.accent
        label.textAlignment = .left
        label.textColor = Colors.Text.red
        label.numberOfLines = 0
        return label
    }()
    
    // Validation
    private let validationLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your email."
        label.font = Fonts.accent
        label.textAlignment = .left
        label.textColor = Colors.Text.main
        return label
    }()
    
    // MARK: - Email TextField
    // 이메일 컨테이너: 아이콘 + 텍스트필드
    private let emailContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Theme.textBackground
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
    // 이메일 아이콘
    private let emailIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.email
        imageView.tintColor = Colors.Theme.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 이메일 텍스트필드
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "E - mail"
        textField.keyboardType = .emailAddress
        textField.clearButtonMode = .whileEditing
        textField.font = Fonts.accent
        textField.textColor = Colors.Text.main
        textField.textAlignment = .left
        textField.returnKeyType = .done
        textField.textContentType = .emailAddress
        // 자동 대문자 방지
        textField.autocapitalizationType = .none
        // 맞춤법 수정 비활성화
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    // MARK: - Apple Container
    // Apple 재인증 버튼
    let appleReauthButton: UIButton = {
//        var config = UIButton.Configuration.filled()
//        var attributedTitle = AttributedString("Verify with Apple")
//        attributedTitle.font = Fonts.accent
//        attributedTitle.foregroundColor = Colors.Text.main
//        config.attributedTitle = attributedTitle
//        config.baseBackgroundColor = Colors.Theme.textBackground
//        
//        let button = UIButton(configuration: config)
//        button.layer.cornerRadius = 14
//        button.isHidden = true
//        return button
        let b = UIButton(type: .system)
        
        // 아이콘 + 텍스트
        b.setTitle(" Verify with Apple", for: .normal)
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
    
    
    // MARK: - UIButton
    // Agree Button
    let agreeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        // 버튼 텍스트 설정
        var attributedTitle = AttributedString("I agree to delete my account.")
        attributedTitle.foregroundColor = Colors.Text.main
        attributedTitle.font = Fonts.accent
        config.attributedTitle = attributedTitle
        // 버튼 아이콘 설정
        let symbolConfig = UIImage.SymbolConfiguration(weight: .semibold)
        config.image = UIImage(systemName: "checkmark", withConfiguration: symbolConfig)
        // 배경
        config.baseBackgroundColor = .clear
        // 아이콘과 텍스트 사이 간격
        config.imagePadding = 20
        
        let button = UIButton(configuration: config)
        // 정렬
        button.contentHorizontalAlignment = .leading
        // 버튼 선택 여부에 따라 아이콘 색상 변경
        button.configurationUpdateHandler = { button in
            if button.isSelected {
                button.tintColor = Colors.Theme.primary
            } else {
                button.tintColor = Colors.Theme.inactive
            }
        }
        return button
    }()
    
    // Delete Button
    let deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        // 버튼 텍스트 설정
        var attributedTitle = AttributedString("Delete my account")
        attributedTitle.foregroundColor = Colors.Theme.cardBackground
        attributedTitle.font = Fonts.headline
        config.attributedTitle = attributedTitle
        // 배경
        config.baseBackgroundColor = Colors.Theme.primary
        
        let button = UIButton(configuration: config)
        // 버튼 활성화 여부에 따라 배경 및 텍스트 색상 변경
        button.configurationUpdateHandler = { button in
            var tempConfig = button.configuration
            if button.isEnabled {
                tempConfig?.baseBackgroundColor = Colors.Theme.primary
                tempConfig?.attributedTitle?.foregroundColor = Colors.Theme.cardBackground
            } else {
                tempConfig?.baseBackgroundColor = Colors.Theme.inactive
                tempConfig?.attributedTitle?.foregroundColor = Colors.Text.additionalInfo
            }
            button.configuration = tempConfig
        }
        // 비활성화
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Loading View
    let loadingView: LoadingView = {
        let view = LoadingView()
        view.descriptionLabel.text = "Loading Account..."
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
        loadingView.stopLoading()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        backgroundColor = Colors.Theme.mainBackground
        addSubview(cardView)
        addSubview(loadingView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(cautionLabel)
        cardView.addSubview(emailContainer)
        cardView.addSubview(appleReauthButton)
        cardView.addSubview(validationLabel)
        cardView.addSubview(agreeButton)
        cardView.addSubview(deleteButton)
        emailContainer.addSubview(emailIconView)
        emailContainer.addSubview(emailTextField)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-18)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide).inset(22)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.top).offset(100)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        cautionLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        emailContainer.snp.makeConstraints {
            $0.top.equalTo(cautionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
        
        appleReauthButton.snp.makeConstraints {
            $0.bottom.equalTo(cardView).offset(-48)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
        
        emailIconView.snp.makeConstraints {
            $0.centerY.equalTo(emailContainer)
            $0.leading.equalTo(emailContainer).offset(16)
            $0.width.height.equalTo(30)
        }
        
        emailTextField.snp.makeConstraints {
            $0.centerY.equalTo(emailContainer)
            $0.leading.equalTo(emailIconView.snp.trailing).offset(12)
            $0.trailing.equalTo(emailContainer).offset(-12)
        }
        
        validationLabel.snp.remakeConstraints {
            $0.top.equalTo(emailContainer.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(emailContainer).inset(16)
        }
        
        deleteButton.snp.makeConstraints {
            $0.bottom.equalTo(cardView).offset(-48)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
        
        agreeButton.snp.makeConstraints {
            $0.bottom.equalTo(deleteButton.snp.top).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

// MARK: - 외부 호출 UI 업데이트 메서드
extension AccountDeletingView {
    // MARK: - Email Validation
    // 이메일 유효성을 나타내기 위한 열거형
    enum emailValidateResult {
        case valid
        case invalid
        case notEntered
    }
    
    // 입력한 이메일에 대한 상태 텍스트 변경 메서드
    func changeValidationLabel(state: emailValidateResult) {
        switch state {
        case .valid:
            validationLabel.text = "The email matches correctly."
            validationLabel.textColor = Colors.Text.green
        case .invalid:
            validationLabel.text = "The email does not match."
            validationLabel.textColor = Colors.Text.red
        case .notEntered:
            validationLabel.text = "Please enter your email."
            validationLabel.textColor = Colors.Text.main
        }
    }
    
    // MARK: - Button
    // Agree Button
    func setAgreeButtonSelection(to isSelected: Bool) {
        agreeButton.isSelected = isSelected
    }
    
    // Delete Button
    func setDeleteButtonAvailability(to isEnabled: Bool) {
        deleteButton.isEnabled = isEnabled
    }
    
    // MARK: - Verification Policy UI
    func applyVerificationPolicy(_ policy: AccountDeletingViewModel.DeletionVerificationPolicy) {
        switch policy {
        case .reenterEmail:
            descriptionLabel.text = "Please enter your registered email address for verification."
            emailContainer.isHidden = false
            validationLabel.isHidden = false
            appleReauthButton.isHidden = true
            deleteButton.isHidden = false

        case .reauthenticateWithApple:
            descriptionLabel.text = "Verify with Apple to delete your account."
            emailContainer.isHidden = true
            validationLabel.isHidden = true
            appleReauthButton.isHidden = false
            deleteButton.isHidden = true

        case .confirmOnly:
            descriptionLabel.text = "Review the notice below and confirm to delete your account."
            emailContainer.isHidden = true
            validationLabel.isHidden = true
            appleReauthButton.isHidden = true
            deleteButton.isHidden = false
        }
    }
}


// MARK: - Preview
#if DEBUG
struct AccountDeletingViewPreview: UIViewRepresentable {
    let policy: AccountDeletingViewModel.DeletionVerificationPolicy
    
    func makeUIView(context: Context) -> AccountDeletingView {
        let view = AccountDeletingView()
        view.applyVerificationPolicy(policy)
        if case .reauthenticateWithApple = policy {
            view.appleReauthButton.isEnabled = false
        }
        view.setAgreeButtonSelection(to: false)
        view.setDeleteButtonAvailability(to: false)
        return view
    }
    
    func updateUIView(_ uiView: AccountDeletingView, context: Context) {
        uiView.applyVerificationPolicy(policy)
    }
}

#Preview("Apple Reauthentication") {
    AccountDeletingViewPreview(policy: .reauthenticateWithApple(email: nil))
        .ignoresSafeArea()
}
#endif
