//
//  ViewPresetListCell.swift
//  Gustav
//
//  Created by kaeun on 3/19/26.
//

import UIKit
import SnapKit

final class ViewPresetListCellView: UITableViewCell {
    
    static let identifier = "ViewPresetListCell"
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.font = Fonts.body
        titleLabel.textColor = Colors.Text.main
        titleLabel.numberOfLines = 1
        
        subtitleLabel.font = Fonts.caption
        subtitleLabel.textColor = Colors.Text.additionalInfo
        subtitleLabel.numberOfLines = 1
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(40)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupStyle() {
        backgroundColor = Colors.Theme.cardBackground
        contentView.backgroundColor = .clear
        
        selectionStyle = .default
        accessoryType = .disclosureIndicator
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
