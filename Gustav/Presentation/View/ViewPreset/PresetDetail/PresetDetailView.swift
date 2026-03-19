//
//  PresetDetailView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit
import SnapKit

final class PresetDetailView: UIView {
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    private let viewSectionLabel = UILabel()
    private let sortSectionLabel = UILabel()
    private let filterSectionLabel = UILabel()
    
    let viewTypeRow = OptionRowView()
    let sortByRow = OptionRowView()
    let sortOrderRow = OptionRowView()
    let categoryRow = OptionRowView()
    let locationRow = OptionRowView()
    let itemStatusRow = OptionRowView()
    
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
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        
        setupSectionLabel(viewSectionLabel, text: "보기")
        setupSectionLabel(sortSectionLabel, text: "정렬")
        setupSectionLabel(filterSectionLabel, text: "필터")
        
        let viewSectionStack = makeSectionStack(
            titleLabel: viewSectionLabel,
            rows: [viewTypeRow]
        )
        
        let sortSectionStack = makeSectionStack(
            titleLabel: sortSectionLabel,
            rows: [sortByRow, sortOrderRow]
        )
        
        let filterSectionStack = makeSectionStack(
            titleLabel: filterSectionLabel,
            rows: [categoryRow, locationRow, itemStatusRow]
        )
        
        mainStackView.addArrangedSubview(viewSectionStack)
        mainStackView.addArrangedSubview(sortSectionStack)
        mainStackView.addArrangedSubview(filterSectionStack)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        [viewTypeRow, sortByRow, sortOrderRow, categoryRow, locationRow, itemStatusRow].forEach { row in
            row.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
    
    private func setupStyle() {
        backgroundColor = Colors.Theme.mainBackground
    }
    
    // MARK: - Configure
    func configure(
        viewType: String,
        sortingOption: String?,
        sortingOrder: String?,
        category: String?,
        location: String?,
        itemStatus: String?
    ) {
        viewTypeRow.configure(title: "보기 타입", value: viewType)
        sortByRow.configure(title: "정렬 기준", value: sortingOption ?? "없음")
        sortOrderRow.configure(title: "정렬 순서", value: sortingOrder ?? "없음")
        categoryRow.configure(title: "카테고리", value: category ?? "없음")
        locationRow.configure(title: "장소", value: location ?? "없음")
        itemStatusRow.configure(title: "아이템 상태", value: itemStatus ?? "없음")
    }
    
    // MARK: - Helpers
    private func setupSectionLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = Fonts.caption
        label.textColor = Colors.Text.additionalInfo
    }
    
    private func makeSectionStack(titleLabel: UILabel, rows: [OptionRowView]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        stackView.addArrangedSubview(titleLabel)
        rows.forEach { stackView.addArrangedSubview($0) }
        
        return stackView
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview {
    PresetDetailPreview()
}

@available(iOS 17.0, *)
private struct PresetDetailPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = PresetDetailView()
        view.configure(
            viewType: "기본",
            sortingOption: "없음",
            sortingOrder: "오름차순",
            category: nil,
            location: nil,
            itemStatus: nil
        )
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
