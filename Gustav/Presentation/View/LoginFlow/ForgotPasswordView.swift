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
    private let scrollView = UIScrollView()
    private let headerStack = UIStackView()
    private let formStack = UIStackView()
    
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

        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false

        headerStack.axis = .vertical
        headerStack.alignment = .fill
        headerStack.distribution = .fill
        headerStack.spacing = 32

        formStack.axis = .vertical
        formStack.alignment = .fill
        formStack.distribution = .fill
        formStack.spacing = 12

        addSubview(cardView)
        cardView.addSubview(scrollView)
        cardView.addSubview(formStack)
        scrollView.addSubview(headerStack)

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(DescriptionLabel)

        formStack.addArrangedSubview(emailInputView)
        formStack.addArrangedSubview(SendEmailButton)
    }

    // Layout 설정
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

        // 버튼 높이 고정
        SendEmailButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}
