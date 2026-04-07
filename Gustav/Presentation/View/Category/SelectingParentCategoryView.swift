//
//  z.swift
//  Gustav
//
//  Created by 박선린 on 4/6/26.
//
import UIKit
import SnapKit

final class SelectingParentCategoryView: UIView {
    
    // MARK: - UI
    
    private let titleTextLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    private let rightStack = UIStackView()
    private let containerStack = UIStackView()
    
    // 실제 메뉴를 담당하는 버튼
    private let menuButton = UIButton(type: .system)
    
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
        
        // right stack
        rightStack.axis = .horizontal
        rightStack.spacing = 4
        rightStack.alignment = .center
        
        rightStack.addArrangedSubview(valueLabel)
        rightStack.addArrangedSubview(chevronImageView)
        
        // 버튼 설정
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.backgroundColor = .clear
        
        // 버튼을 rightStack 위에 얹음
        rightStack.addSubview(menuButton)
        
        // container stack
        containerStack.axis = .horizontal
        containerStack.alignment = .center
        
        containerStack.addArrangedSubview(titleTextLabel)
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
            make.size.equalTo(16)
        }
        
        // 버튼을 rightStack 전체 덮도록
        menuButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupStyle() {
        backgroundColor = Colors.Theme.cardBackground
        layer.cornerRadius = 14
        clipsToBounds = true
    }
    
    // MARK: - Configure
    
    func configure(title: String, value: String, menu: UIMenu?) {
        titleTextLabel.text = title
        valueLabel.text = value
        menuButton.menu = menu
    }
}
