//
//  ForgotPasswordView.swift
//  Gustav
//
//  Created by kaeun on 3/13/26.
//


import UIKit
import SnapKit

class ForgotPasswordView: UIView {
    
    // MARK: - UI
    
    private let cardView = UIView()
    private let contentStack = UIStackView()
    
    let emailInputView = AuthInputFieldView(kind: .email)
    
    // 이메일 보내기 버튼
    let SendEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send verification mail", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.headline
        button.backgroundColor = Colors.Theme.primary
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        return button
    }()


    // Title
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "E-mail Verification"
        lb.font = Fonts.largeTitle
        lb.textAlignment = .left
        lb.textColor = .label
        lb.numberOfLines = 0
        return lb
    }()
    
    // Description
    private let DescriptionLabel: UILabel = {
        let lb = UILabel()
        lb.text = """
        Please enter your registered email address.
        We’ll send a verification mail to the address.
        """
        lb.font = Fonts.body
        lb.textAlignment = .left
        lb.textColor = .label
        lb.numberOfLines = 0
        return lb
    }()
    
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


private extension ForgotPasswordView {

    // UI 구성
    func setupUI() {
        
        backgroundColor = Colors.Theme.mainBackground

        // 카드 스타일
        cardView.backgroundColor = Colors.Theme.cardBackground
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true

        // 카드 내부 패딩
        cardView.layoutMargins = UIEdgeInsets(top: 100, left: 16, bottom: 16, right: 16)

        // StackView 설정
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 16

        addSubview(cardView)
        addSubview(contentStack)

        // StackView 내부 구성
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(DescriptionLabel)
        
        // 아래 간격 추가
        contentStack.setCustomSpacing(300, after: DescriptionLabel)
        
        contentStack.addArrangedSubview(emailInputView)
        contentStack.addArrangedSubview(SendEmailButton)
    }

    // Layout 설정
    func setupLayout() {

        cardView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }

        // 스택은 카드 margin 기준으로 꽉 채움
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(cardView.layoutMarginsGuide)
        }

        // 버튼 높이 고정
        SendEmailButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}
