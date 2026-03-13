//
//  LoginView.swift
//  Gustav
//
//  Created by kaeun on 3/4/26.
//

import UIKit
import SnapKit

final class LoginView: UIView {

    // MARK: - UI
    private let cardView = UIView()
    private let contentStack = UIStackView()


    // Welcome
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Welcome!"
        lb.font = Fonts.largeTitle
        lb.textAlignment = .center
        lb.textColor = .label
        return lb
    }()

//    private let titleLabelBox: UIView = {
//        let v = UIView()
//        v.backgroundColor = Colors.Theme.cardBackground
//        v.layer.masksToBounds = true
//        return v
//    }()
    
    let formView = LoginFormView()

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

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = Colors.Theme.mainBackground

        // 카드 스타일
        cardView.backgroundColor = Colors.Theme.cardBackground
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true

        // 카드 내부 패딩
        cardView.layoutMargins = UIEdgeInsets(top: 26, left: 16, bottom: 48, right: 16)

        // 카드 내부 스택
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.spacing = 48

        addSubview(cardView)
        cardView.addSubview(contentStack)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(42, after: titleLabel) // 스샷처럼 타이틀 아래 공간 크게
        contentStack.addArrangedSubview(formView)
        
    }

    private func setupLayout() {
        // 작은 화면에서도 카드 깨짐 방지 (top>=, bottom<=, centerY)
        cardView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(80)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }
        
        // 스택은 카드 margin 기준으로 꽉 채움
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(cardView.layoutMarginsGuide)
        }
        
        
    }
}

extension LoginView {
    var emailText: String {
        formView.emailText
    }

    var passwordText: String {
        formView.passwordText
    }
}
