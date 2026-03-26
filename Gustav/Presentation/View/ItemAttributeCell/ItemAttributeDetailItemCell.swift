//
//  ItemAttributeDetailItemCell.swift
//  Gustav
//
//  Created by 박선린 on 3/24/26.
//

import UIKit
import SnapKit

class ItemAttributeDetailItemCell: UITableViewCell {
    static let reuseID = "ItemAttributeDetailItemCell"
    
    private let spacing: CGFloat = 16
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = Colors.Text.main
        l.textAlignment = .left
        l.numberOfLines = 1
        return l
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
    }
    
    private func setupLayout() {
        self.contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(spacing)
            $0.height.greaterThanOrEqualTo(20)
        }
    }
    
    // MARK: - Configure
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    // 재사용 이슈 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
}
