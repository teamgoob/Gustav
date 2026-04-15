//
//  PresetAddView.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit
import SnapKit

final class PresetAddView: UIView {
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    private let viewSectionLabel = UILabel()
    private let nameSectionLabel = UILabel()
    private let sortSectionLabel = UILabel()
    private let filterSectionLabel = UILabel()
    
    let nameCardView = ItemAddTextFieldCardView(
        style: .single,
        firstPlaceholder: "Preset name"
    )
    let viewTypeRow = OptionRowView()
    let sortByRow = OptionRowView()
    let sortOrderRow = OptionRowView()
    let categoryRow = OptionRowView()
    let subcategoryRow = OptionRowView()
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
        subcategoryRow.isHidden = true
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        
        setupSectionLabel(nameSectionLabel, text: "Name")
        setupSectionLabel(viewSectionLabel, text: "View")
        setupSectionLabel(sortSectionLabel, text: "Sort")
        setupSectionLabel(filterSectionLabel, text: "Filter")
        
        let nameSectionStack = makeSectionStack(
            titleLabel: nameSectionLabel,
            rows: [nameCardView]
        )
        
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
            rows: [categoryRow, subcategoryRow, locationRow, itemStatusRow]
        )
        
        mainStackView.addArrangedSubview(nameSectionStack)
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
        
        [nameCardView, viewTypeRow, sortByRow, sortOrderRow, categoryRow, subcategoryRow, locationRow, itemStatusRow].forEach { row in
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
        name: String,
        viewType: String,
        sortingOption: String?,
        sortingOrder: String?,
        category: String?,
        subcategory: String?,
        showsSubcategory: Bool,
        location: String?,
        itemStatus: String?
    ) {
        nameCardView.setFirstText(name)
        viewTypeRow.configure(title: "Display Style", value: viewType)
        sortByRow.configure(title: "Sort By", value: sortingOption ?? "Updated at")
        sortOrderRow.configure(title: "Sort Order", value: sortingOrder ?? "Descending order")
        categoryRow.configure(title: "Category", value: category ?? "None")
        subcategoryRow.configure(title: "Subcategory", value: subcategory ?? "None")
        subcategoryRow.isHidden = !showsSubcategory
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
