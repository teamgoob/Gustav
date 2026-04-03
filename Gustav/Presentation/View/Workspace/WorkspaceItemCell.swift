//
//  WorkspaceItemCell.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import UIKit
import SnapKit

// MARK: - WorkspaceItemCellData
// 워크스페이스 아이템 하나의 셀 데이터
struct WorkspaceItemCellData {
    // Item ID
    let id: UUID
    // 사용자 정의 아이템 순서
    let indexKey: Int
    // Item Name
    let name: String
    // 마지막 수정일
    let updatedAt: String
    // 기본 상태에서 표시될 강조 속성
    let baseProperties: [WorkspaceItemPropertyData]
    // 확장 상태에서 추가로 표시될 속성
    let expandedProperties: [WorkspaceItemPropertyData]
    // 확장 여부
    var isExpanded: Bool
}

// MARK: - WorkspaceItemCell
// 워크스페이스 아이템 목록 셀 뷰
final class WorkspaceItemCell: UITableViewCell {
    static let identifier: String = "WorkspaceItemCell"
    
    // MARK: - Header
    // 아이템 이름
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.accent
        label.textColor = Colors.Text.main
        label.numberOfLines = 1
        return label
    }()
    // 아이템 삭제 버튼
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = Colors.Theme.red.withAlphaComponent(0.6)
        return button
    }()
    // 아이템 수정 버튼
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = Colors.Text.main
        return button
    }()
    // 셀 확장 버튼
    private let expandButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = Colors.Text.main
        return button
    }()
    // 헤더 스택 뷰
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(expandButton)
        return stackView
    }()
    // MARK: - Property Stack
    // 강조된 속성
    private let basePropertyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()
    // 전체 속성
    private let expandedPropertyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()
    // MARK: - Footer
    // 마지막 수정일
    private let updatedAtLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.caption
        label.textColor = Colors.Text.additionalInfo
        label.textAlignment = .right
        return label
    }()
    // MARK: - Container
    // 컨텐츠를 담는 스택 뷰
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.addArrangedSubview(headerStackView)
        stackView.addArrangedSubview(basePropertyStackView)
        stackView.addArrangedSubview(expandedPropertyStackView)
        stackView.addArrangedSubview(updatedAtLabel)
        return stackView
    }()
    // 스택 뷰를 담는 셀 영역
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Theme.cardBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Closures
    // 아이템 삭제 버튼 선택
    var onDeleteButtonTapped: (() -> Void)?
    // 아이템 수정 버튼 선택
    var onEditButtonTapped: (() -> Void)?
    // 셀 확장 버튼 선택
    var onExpandButtonTapped: (() -> Void)?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupViews()
        setupActions()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(containerStackView)
    }
    // 버튼 타겟 메서드 설정
    private func setupActions() {
        // 아이템 삭제 버튼 타겟 메서드 등록
        deleteButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
        // 아이템 수정 버튼 타겟 메서드 등록
        editButton.addTarget(
            self,
            action: #selector(editButtonTapped),
            for: .touchUpInside
        )
        // 셀 확장 버튼 타겟 메서드 등록
        expandButton.addTarget(
            self,
            action: #selector(expandButtonTapped),
            for: .touchUpInside
        )
    }
    // 오토레이아웃 설정
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(2)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Target Methods
    @objc private func deleteButtonTapped() {
        onDeleteButtonTapped?()
    }
    @objc private func editButtonTapped() {
        onEditButtonTapped?()
    }
    @objc private func expandButtonTapped() {
        onExpandButtonTapped?()
    }
    
    // MARK: - Configuration Methods
    // 셀 초기화
    func configure(with cellData: WorkspaceItemCellData) {
        // 아이템 이름, 마지막 수정일 설정
        titleLabel.text = cellData.name
        updatedAtLabel.text = cellData.updatedAt
        
        // 강조 속성 및 일반 속성 추가, 확장 버튼 아이콘 변경
        configureBaseProperties(cellData.baseProperties)
        configureExpandedProperties(cellData.expandedProperties, cellData.isExpanded)
        configureExpandButtonIcon(cellData.isExpanded)
    }
    // 강조 속성 초기화
    private func configureBaseProperties(_ properties: [WorkspaceItemPropertyData]) {
        // 기존 하위 뷰 제거
        basePropertyStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        // 새로운 데이터로 속성 뷰를 만들어 추가
        properties.forEach {
            let view = WorkspaceItemPropertyView(with: $0)
            basePropertyStackView.addArrangedSubview(view)
        }
    }
    // 일반 속성 초기화
    private func configureExpandedProperties(_ properties: [WorkspaceItemPropertyData], _ isExpanded: Bool) {
        // 기존 하위 뷰 제거
        expandedPropertyStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        // 확장 상태인 경우, 스택 뷰 표시
        expandedPropertyStackView.isHidden = !isExpanded
        // 확장 상태인 경우, 새로운 데이터로 속성 뷰를 만들어 추가
        guard isExpanded else { return }
        properties.forEach {
            let view = WorkspaceItemPropertyView(with: $0)
            expandedPropertyStackView.addArrangedSubview(view)
        }
    }
    // 셀 확장 버튼 아이콘 초기화
    private func configureExpandButtonIcon(_ isExpanded: Bool) {
        // 확장 여부에 따라 아이콘 결정
        let icon = isExpanded ? "chevron.up" : "chevron.down"
        expandButton.setImage(UIImage(systemName: icon), for: .normal)
    }
}
