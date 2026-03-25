//
//  ProfileImageView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/23.
//

import UIKit
import SnapKit

// MARK: - ProfileImageView
// 프로필 이미지 뷰 - 프로필 이미지 + 카메라 모양 아이콘
final class ProfileImageView: UIView {
    // MARK: - UI Components
    // Profile Image
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = Colors.Theme.inactive
        imageView.layer.cornerRadius = 100
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Camera Icon
    private let cameraIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "camera.circle.fill")
        icon.tintColor = Colors.Text.main.withAlphaComponent(0.9)
        icon.backgroundColor = Colors.Theme.mainBackground
        icon.layer.cornerRadius = 24
        icon.clipsToBounds = true
        return icon
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
        addSubview(imageView)
        addSubview(cameraIcon)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cameraIcon.snp.makeConstraints {
            $0.width.height.equalTo(48)
            $0.trailing.bottom.equalToSuperview().inset(10)
        }
    }
}
