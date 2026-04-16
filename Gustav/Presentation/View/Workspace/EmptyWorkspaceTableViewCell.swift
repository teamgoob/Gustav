//
//  EmptyWorkspaceTableViewCell.swift
//  Gustav
//
//  Created by 박선린 on 4/2/26.
//

import UIKit
import SnapKit

class EmptyWorkspaceTableViewCell: UITableViewCell {
    static let reuseID = "EmptyWorkspaceTableViewCell"
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Fonts.body
        l.textColor = Colors.Text.main
        l.textAlignment = .center
        l.numberOfLines = 0
        l.text = "Create a new workspace to get started"
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
        
        contentView.addSubview(titleLabel)
    }
    
    private func setupLayout() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
    }
}
