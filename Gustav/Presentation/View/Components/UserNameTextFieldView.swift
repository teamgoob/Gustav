//
//  UserNameTextFieldView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/23.
//

import UIKit
import SnapKit

// MARK: - UserNameTextFieldView
// 사용자 이름 텍스트필드 뷰 - 텍스트필드 + 밑줄 + 연필 모양 아이콘
final class UserNameTextFieldView: UIView {
    // MARK: - UI Components
    // Name TextField
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .clear
        textField.font = Fonts.largeTextField
        textField.textColor = Colors.Text.main
        textField.textAlignment = .center
        textField.returnKeyType = .done
        // 자동 대문자 방지
        textField.autocapitalizationType = .none
        // 맞춤법 수정 비활성화
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    // Underline
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Text.main.withAlphaComponent(0.8)
        return view
    }()
    
    // Pencil Icon
    private let pencilIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil")
        imageView.tintColor = Colors.Text.main.withAlphaComponent(0.8)
        return imageView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        backgroundColor = .clear
        addSubview(textField)
        addSubview(underlineView)
        addSubview(pencilIcon)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        textField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalTo(pencilIcon.snp.leading).offset(-8)
        }
        pencilIcon.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalToSuperview().inset(4)
            $0.width.height.equalTo(20)
        }
        underlineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
}
