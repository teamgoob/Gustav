//
//  ParentCategoryTableViewCell.swift
//  Gustav
//
//  Created by 박선린 on 4/6/26.
//

import UIKit
import SnapKit

class DisabledParentCategoryCell: UITableViewCell {
    static let reuseID = "DisabledParentCategoryCell"
    
    private let spacing: CGFloat = 4
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Colors.Text.additionalInfo
        label.text = "No categories available to select"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = Colors.Theme.cardBackground
        contentView.backgroundColor = Colors.Theme.cardBackground
        self.titleLabel.backgroundColor = Colors.Theme.cardBackground
    }
    
    private func setupLayout() {
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(self.spacing)
        }
    }
    
    // MARK: - Configure
    
    func configure() {
    }
    
    // 재사용 이슈 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
