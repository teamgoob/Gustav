//
//  WorkspaceNameEditCell.swift
//  Gustav
//
//  Created by 박선린 on 3/5/26.
//

import UIKit
import SnapKit

// MARK: - 워크스페이스 이름 변경 셀
class WorkspaceNameEditCell: UITableViewCell {
    static let reuseID = "WorkspaceNameEditCell"
    
    // 셀의 텍스트가 변경되었을 때 바깥으로 전달하는 클로저
    var onTextChanged: ((String) -> Void)?
    
    // MARK: - UI
    
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 16, weight: .semibold)
        tf.textColor = .black
        tf.textAlignment = .center
        tf.returnKeyType = .done
        return tf
    }()
    
    let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .secondaryLabel
        return btn
    }()
    
    private let updatedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .right
        l.numberOfLines = 1
        return l
    }()
    
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTargetSetUp()
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    private func addTargetSetUp() {
        clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(nameTextField)
        cardView.addSubview(clearButton)
        contentView.addSubview(updatedLabel)
    }
    
    private func setupLayout() {
        
        cardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.equalTo(272)
        }
        
        nameTextField.snp.makeConstraints {
            // 왼쪽 꽉 채우는 것을 원한다면 이것
            //$0.top.leading.bottom.equalToSuperview()
            
            
            // 오른쪽의 클리어 버튼영역과 동일한 사이즈의 여백을 주고 싶으면 아래 사용
            $0.top.bottom.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(44)
        }
        
        clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(24)
            $0.trailing.equalToSuperview().offset(-10)
            $0.leading.equalTo(nameTextField.snp.trailing).offset(10)
        }
        
        updatedLabel.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(6)
            $0.trailing.equalTo(cardView)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: - Configure
    
    func configure(title: String, updatedAt: Date) {
        self.nameTextField.text = title
        self.updatedLabel.text = "마지막 수정일 : \(updatedAt.formatDateyyyyMMdd())"
    }
    
    // didTapClearButton
    @objc private func didTapClearButton() {
        nameTextField.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        // 재사용 전에 이전 상태를 초기화
        nameTextField.text = nil
        onTextChanged = nil
    }
}

extension WorkspaceNameEditCell: UISearchTextFieldDelegate {
    // nameTextField의 text 속성 변경 이벤트 
    @objc private func textDidChange() {
        onTextChanged?(nameTextField.text ?? "")
    }
}
