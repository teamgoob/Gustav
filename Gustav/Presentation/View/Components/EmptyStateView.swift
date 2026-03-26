//
//  EmptyStateView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/27.
//

import UIKit
import SnapKit

// MARK: - EmptyStateView
// 불러온 데이터가 없을 때 표시하는 화면
final class EmptyStateView: UIView {
    // MARK: - UI Components
    // Description Label
    private let label: UILabel = {
        let label = UILabel()
        label.text = "There's no items."
        label.font = Fonts.headline
        label.textColor = Colors.Text.main
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializer
    init(message: String) {
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
        configure(message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        backgroundColor = Colors.Theme.mainBackground
        addSubview(label)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    private func configure(message: String) {
        label.text = message
    }
}
