//
//  PresetOptionRowView.swift
//  Gustav
//
//  Created by kaeun on 3/19/26.
//

import UIKit
import SnapKit

class OptionRowView: UIButton {
    
    // MARK: - UI
    
    private let titleTextLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    private let rightStack = UIStackView()
    private let containerStack = UIStackView()
    
    // MARK: - Callback
    var onTap: (() -> Void)?
    
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
        titleTextLabel.font = Fonts.body
        titleTextLabel.textColor = Colors.Text.main
        
        // value
        valueLabel.font = Fonts.body
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
        containerStack.addArrangedSubview(titleTextLabel)
        containerStack.addArrangedSubview(UIView()) // spacer
        containerStack.addArrangedSubview(rightStack)
        
        containerStack.isUserInteractionEnabled = false

        addSubview(containerStack)
        addTarget(self, action: #selector(didTapRow), for: .touchUpInside)
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
    
    // MARK: - Configure
    
    func configure(title: String, value: String) {
        titleTextLabel.text = title
        valueLabel.text = value
    }
    
    @objc private func didTapRow() {
        onTap?()
    }
}
