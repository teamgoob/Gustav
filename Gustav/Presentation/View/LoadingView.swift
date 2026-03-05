//
//  LoadingView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/6.
//

import UIKit
import SnapKit

// MARK: - LoadingView
// 로딩 중 화면
final class LoadingView: UIView {
    // MARK: - UI Components
    // Loading Indicator
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Colors.Theme.primary
        indicator.hidesWhenStopped = false
        return indicator
    }()
    
    // 설명 텍스트
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body
        label.textColor = Colors.Text.main
        label.textAlignment = .center
        label.text = "Loading..."
        return label
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
        backgroundColor = Colors.Theme.background2
        addSubview(loadingIndicator)
        addSubview(descriptionLabel)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(loadingIndicator.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    // MARK: - Visible / Animation Control
    func startLoading() {
        isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
        isHidden = true
    }
}
