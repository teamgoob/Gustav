//
//  WorkSpaceReorderingCell.swift
//  Gustav
//
//  Created by 박선린 on 3/10/26.
//

import UIKit
import SnapKit

class ItemAttributeReorderingCell: UITableViewCell {

    static let reuseID = "ItemAttributeReorderCell"
    
    private let spacing: CGFloat = 16
    
    // MARK: - UI
    
    private let circlefill: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "circle.fill")
        iv.tintColor = .red
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Fonts.body
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
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
    }
    
    private func setupLayout() {
        self.contentView.addSubview(circlefill)
        self.contentView.addSubview(titleLabel)
        
        circlefill.snp.makeConstraints {
            $0.height.width.equalTo(20)
            $0.leading.equalTo(self.contentView).offset(spacing)
            $0.centerY.equalTo(self.contentView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(self.circlefill.snp.trailing).offset(spacing)
            $0.trailing.equalTo(self.contentView.snp.trailing).offset(-spacing)
            $0.centerY.equalTo(self.contentView)
        }
        
    }
    
    // MARK: - Configure
    
    func configure(title: String, tagColor: TagColor) {
        titleLabel.text = title
        circlefill.tintColor = tagColor.uiColor
    }
    
    // 재사용 이슈 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
