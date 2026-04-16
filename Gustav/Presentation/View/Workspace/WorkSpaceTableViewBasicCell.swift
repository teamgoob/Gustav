//
//  WorkSpaceTableViewBasicCell.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit

class WorkSpaceTableViewBasicCell: UITableViewCell {
    static let reuseID = "WorkSpaceTableViewBasicCell"
    
    // MARK: - UI
    
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = Colors.Theme.cardBackground
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Fonts.body
        l.textColor = Colors.Text.main
        l.font = Fonts.body
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()
    
    private let updatedLabel: UILabel = {
        let l = UILabel()
        l.font = Fonts.additional
        l.textColor = Colors.Text.additionalInfo
        l.textAlignment = .right
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        contentView.addSubview(updatedLabel)
    }
    
    private func setupLayout() {
        cardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.equalTo(272)
        }
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        updatedLabel.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(6)
            $0.trailing.equalTo(cardView)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: - Configure
    
    func configure(title: String, updatedAt: Date) {
        titleLabel.text = title
        updatedLabel.text = "마지막 수정일 : \(updatedAt.formatDateyyyyMMdd())"
    }
    
    // 재사용 이슈 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        updatedLabel.text = nil
    }
    
}
