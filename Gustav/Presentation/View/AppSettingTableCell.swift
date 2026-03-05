//
//  AppSettingTableCell.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/4.
//

import UIKit
import SnapKit

// MARK: - AppSettingTableCell
// 앱 설정 목록 테이블 뷰 셀
final class AppSettingTableCell: UITableViewCell {
    
    static let identifier: String = "AppSettingTableCell"
    
    // MARK: - Cell UI
    // Cell Container
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // Cell Icon
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.Theme.primary
        return imageView
    }()
    
    // Cell Title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.body
        label.textColor = Colors.Text.main
        return label
    }()
    
    // Cell Arrow
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.Theme.outline
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = Colors.Theme.background
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(52)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
    }
    
    // MARK: - Configure
    // Configure Cell Contents
    func configure(icon: UIImage?, title: String, titleColor: UIColor = Colors.Text.main) {
        iconImageView.image = icon
        titleLabel.text = title
        titleLabel.textColor = titleColor
    }
}
