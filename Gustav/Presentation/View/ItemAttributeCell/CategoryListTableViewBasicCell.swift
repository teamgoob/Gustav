//
//  WorkSpaceTableViewBasicCell.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit

class CategoryListTableViewBasicCell: UITableViewCell {
    static let reuseID = "CategoryListTableViewBasicCell"
    
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
    
    private let childCategoriesLabel: UILabel = {
        let l = UILabel()
        l.font = Fonts.caption
        l.textColor = Colors.Text.additionalInfo
        l.textAlignment = .right
        l.numberOfLines = 1
        return l
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colors.Theme.outline
        return imageView
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
        self.contentView.addSubview(circlefill)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(chevronImageView)
        self.contentView.addSubview(childCategoriesLabel)
        
        circlefill.snp.makeConstraints {
            $0.height.width.equalTo(20)
            $0.leading.equalTo(self.contentView).offset(spacing)
            $0.centerY.equalTo(self.contentView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.equalTo(self.circlefill.snp.trailing).offset(spacing)
            $0.trailing.equalTo(self.childCategoriesLabel.snp.leading).offset(-spacing) // 변경
            $0.centerY.equalTo(self.contentView)
        }
        
        childCategoriesLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.chevronImageView.snp.leading).offset(-spacing)
            $0.centerY.equalTo(self.contentView)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalTo(self.contentView).offset(-spacing)
            $0.centerY.equalTo(self.contentView)
        }
        
        // chevron은 절대 밀리면 안됨
        chevronImageView.setContentHuggingPriority(.required, for: .horizontal)
        chevronImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // child label은 줄어들 수 있음
        childCategoriesLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // title도 상황에 따라 줄어들 수 있게
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    // MARK: - Configure
    
    func configure(title: String, tagColor: TagColor, childCategories: String? = nil) {
        titleLabel.text = title
        circlefill.tintColor = tagColor.uiColor
        
        if let childCategories {
            self.titleLabel.font = Fonts.body
            self.childCategoriesLabel.text = childCategories
            self.childCategoriesLabel.isHidden = false
        } else {
            self.titleLabel.font = Fonts.accent
            self.childCategoriesLabel.text = nil
            self.childCategoriesLabel.isHidden = true
        }
        
    }
    
    // 재사용 이슈 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.font = Fonts.body
        self.titleLabel.text = nil
        self.childCategoriesLabel.text = nil
    }
    
}
