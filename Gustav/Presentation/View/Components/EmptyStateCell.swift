//
//  EmptyStateCell.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/27.
//

import UIKit
import SnapKit

// MARK: - EmptyStateCell
// 불러온 데이터가 없을 때 표시하는 테이블 뷰 셀
final class EmptyStateCell: UITableViewCell {
    static let identifier: String = "EmptyStateCell"
    
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = Colors.Theme.mainBackground
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        contentView.addSubview(label)
    }
    // 오토레이아웃 설정
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
