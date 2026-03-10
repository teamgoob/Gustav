//
//  WorkSpaceReorderingCell.swift
//  Gustav
//
//  Created by 박선린 on 3/10/26.
//

import UIKit
import SnapKit

class WorkSpaceReorderingCell: UITableViewCell {

    static let reuseID = "WorkSpaceReorderCell"
    
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
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = Colors.Text.main
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()
    
    private func setUI() {
        self.contentView.addSubview(cardView)
        self.cardView.addSubview(titleLabel)
        
    }
    
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
    }
    
    private func setupLayout() {
        cardView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.equalTo(272)
        }
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
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
