//
//  ProfileEditingView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/6.
//

import UIKit
import SnapKit

// MARK: - ProfileEditingView
// 프로필 수정 화면
final class ProfileEditingView: UIView {
    // MARK: - Container
    // Content View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Profile Editor
    // Profile Image
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // User Name TextField
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .clear
        textField.font = Fonts.largeTextField
        textField.textAlignment = .center
        return textField
    }()
    
    // MARK: - Loading View
    let loadingView: LoadingView = {
        let view = LoadingView()
        view.descriptionLabel.text = "Loading Profile..."
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
        addSubview(contentView)
        addSubview(loadingView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameTextField)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(200)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
}
