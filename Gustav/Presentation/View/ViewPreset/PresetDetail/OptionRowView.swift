//
//  PresetOptionRowView.swift
//  Gustav
//
//  Created by kaeun on 3/19/26.
//

import UIKit
import SnapKit

class OptionRowView: UIControl {
    
    // MARK: - UI
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    private let rightStack = UIStackView()
    private let containerStack = UIStackView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // title
        titleLabel.font = Fonts.body
        titleLabel.textColor = Colors.Text.main
        
        // value
        valueLabel.font = Fonts.accent
        valueLabel.textColor = .systemBlue
        
        // chevron
        chevronImageView.image = UIImage(systemName: "chevron.up.chevron.down")
        chevronImageView.tintColor = .systemBlue
        chevronImageView.contentMode = .scaleAspectFit
        
        // right stack (옆에 버튼)
        rightStack.axis = .horizontal
        rightStack.spacing = 4
        rightStack.alignment = .center
        rightStack.addArrangedSubview(valueLabel)
        rightStack.addArrangedSubview(chevronImageView)
        
        // container stack (항목명 + 버튼)
        containerStack.axis = .horizontal
        containerStack.alignment = .center
        containerStack.addArrangedSubview(titleLabel)
        containerStack.addArrangedSubview(UIView()) // spacer
        containerStack.addArrangedSubview(rightStack)
        
        addSubview(containerStack)
    }
    
    private func setupLayout() {
        containerStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        
//        사용하려는 상위 뷰에서 높이 조절하기 위해 남겨놓음
//        row.snp.makeConstraints { make in
//            make.height.equalTo(60)
//        }
    }
    
    private func setupStyle() {
        backgroundColor = Colors.Theme.cardBackground
        layer.cornerRadius = 14
        clipsToBounds = true
    }
    
    // MARK: - Highlight
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Colors.Theme.primary : Colors.Theme.cardBackground
        }
    }
    
    // MARK: - Configure
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
