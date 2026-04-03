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
        
        setupSectionLabel(viewSectionLabel, text: "View")
        setupSectionLabel(sortSectionLabel, text: "Sort")
        setupSectionLabel(filterSectionLabel, text: "Filter")
        
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
            make.leading.trailing.equalToSuperview()
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
        viewTypeRow.configure(title: "Display Style", value: viewType)
        sortByRow.configure(title: "Sort By", value: sortingOption ?? "None")
        sortOrderRow.configure(title: "Sort Order", value: sortingOrder ?? "None")
        categoryRow.configure(title: "Category", value: category ?? "None")
        locationRow.configure(title: "Location", value: location ?? "None")
        itemStatusRow.configure(title: "Status", value: itemStatus ?? "None")
    }
    
    // MARK: - Helpers
    private func setupSectionLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = Fonts.caption
        label.textColor = Colors.Text.additionalInfo
    }
    
    private func makeSectionStack(titleLabel: UILabel, rows: [UIView]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        stackView.addArrangedSubview(titleLabel)
        rows.forEach { stackView.addArrangedSubview($0) }
        
        return stackView
    }
}
