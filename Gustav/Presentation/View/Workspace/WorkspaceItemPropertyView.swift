//
//  WorkspaceItemPropertyView.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import UIKit
import SnapKit

// MARK: - WorkspaceItemPropertyData
// 워크스페이스 아이템의 속성 한 줄을 표시하기 위한 데이터
struct WorkspaceItemPropertyData {
    // 속성 구분
    let property: ItemProperty
    // 속성 값
    let value: String
    // 태그 타입 속성인 경우 색상
    let color: TagColor?
    // 속성 강조 여부
    let isHighlighted: Bool
}

// MARK: - WorkspaceItemPropertyView
// 워크스페이스 아이템의 속성 한 줄을 표시하는 뷰
final class WorkspaceItemPropertyView: UIView {
    // MARK: - UI Components
    // 스택 뷰
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    // 속성 이름
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.additional
        label.textColor = Colors.Text.main
        // 허깅(늘어나지 않는 정도) 우선 순위 설정
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    // 속성 값 컨테이너
    private let valueContainer = UIView()
    // 속성 값 (일반 텍스트)
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.caption
        label.textColor = Colors.Text.main
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    // 속성 값 (태그 형태)
    private let tagLabel: TagLabel = {
        let label = TagLabel()
        label.font = Fonts.caption
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    // MARK: - Initializer
    init(with propertyData: WorkspaceItemPropertyData) {
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
        configure(with: propertyData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // 하위 뷰 추가
    private func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(valueContainer)
    }
    
    // 오토레이아웃 설정
    private func setupConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        valueContainer.snp.makeConstraints {
            $0.width.lessThanOrEqualToSuperview().multipliedBy(0.6)
        }
    }
    // 속성 값 컨테이너 초기화
    private func clearValueContainer() {
        // 컨테이너 하위 뷰 삭제
        valueContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    // 속성 초기화
    private func configure(with propertyData: WorkspaceItemPropertyData) {
        // 속성명 초기화
        titleLabel.text = propertyData.property.title
        // 현재 강조 속성인 경우 글자 색상 변경
        titleLabel.textColor = propertyData.isHighlighted ? Colors.Text.highlighted : Colors.Text.main
        
        // 태그 타입 속성인 경우
        if propertyData.property.isTagType {
            clearValueContainer()
            tagLabel.text = propertyData.value
            tagLabel.backgroundColor = propertyData.color?.toUIColor()
            tagLabel.textColor = propertyData.color?.getTextColor()
            valueContainer.addSubview(tagLabel)
            tagLabel.snp.makeConstraints {
                $0.top.bottom.trailing.equalToSuperview()
                $0.leading.greaterThanOrEqualToSuperview()
            }
        } else {
            // 일반 속성인 경우
            clearValueContainer()
            valueLabel.text = propertyData.value
            valueLabel.textColor = propertyData.isHighlighted ? Colors.Text.highlighted : Colors.Text.main
            valueContainer.addSubview(valueLabel)
            valueLabel.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
}
