//
//  ItemAddView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit
import SnapKit

final class ItemAddView: UIView {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()

    let itemNameCardView = ItemAddTextFieldCardView(
        style: .double,
        firstPlaceholder: "Item name",
        secondPlaceholder: "detail name"
    )

    let priceQuantityCardView = ItemAddTextFieldCardView(
        style: .double,
        firstPlaceholder: "price",
        secondPlaceholder: "quantity"
    )

    let memoCardView = ItemMemoCardView()

    let purchasePlaceCardView = ItemAddTextFieldCardView(
        style: .single,
        firstPlaceholder: "Purchased place"
    )

    let purchaseDateCardView = ItemAddDateCardView(
        configuration: .init(
            toggleTitle: "Purchase Date",
            dateTitle: "Date",
            dateText: "",
            timeText: "",
            isOn: true
        )
    )

    let expireDateCardView = ItemAddDateCardView(
        configuration: .init(
            toggleTitle: "Purchase Expire at",
            dateTitle: "Date",
            dateText: "",
            timeText: "",
            isOn: true
        )
    )

    private let optionSectionStackView = UIStackView()
    let categoryRowView = OptionRowView()
    let itemStateRowView = OptionRowView()
    let locationRowView = OptionRowView()

    // MARK: - Callback
    var onTapCategory: (() -> Void)?
    var onTapItemState: (() -> Void)?
    var onTapLocation: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        configureDefaultValues()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configureOptionValues(
        category: String?,
        itemState: String?,
        location: String?
    ) {
        categoryRowView.configure(title: "Category", value: category ?? "none")
        itemStateRowView.configure(title: "Item state", value: itemState ?? "none")
        locationRowView.configure(title: "Location", value: location ?? "none")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = Colors.Theme.mainBackground

        setupMainStackView()
        setupOptionSectionStackView()
        setupInputKeyboardTypes()
        setupMemoPlaceholder()
        setupOptionRowActions()

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)

        mainStackView.addArrangedSubview(itemNameCardView)
        mainStackView.addArrangedSubview(priceQuantityCardView)
        mainStackView.addArrangedSubview(memoCardView)
        mainStackView.addArrangedSubview(purchasePlaceCardView)
        mainStackView.addArrangedSubview(purchaseDateCardView)
        mainStackView.addArrangedSubview(expireDateCardView)
        mainStackView.addArrangedSubview(optionSectionStackView)

        optionSectionStackView.addArrangedSubview(categoryRowView)
        optionSectionStackView.addArrangedSubview(itemStateRowView)
        optionSectionStackView.addArrangedSubview(locationRowView)
    }


    private func setupMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
    }

    private func setupOptionSectionStackView() {
        optionSectionStackView.axis = .vertical
        optionSectionStackView.spacing = 12
        optionSectionStackView.alignment = .fill
        optionSectionStackView.distribution = .fill
    }

    private func setupInputKeyboardTypes() {
        priceQuantityCardView.setFirstKeyboardType(.decimalPad)
        priceQuantityCardView.setSecondKeyboardType(.numberPad)
    }

    private func setupMemoPlaceholder() {
        memoCardView.setPlaceholder("memo")
    }

    private func setupOptionRowActions() {
        categoryRowView.addTarget(self, action: #selector(didTapCategoryRow), for: .touchUpInside)
        itemStateRowView.addTarget(self, action: #selector(didTapItemStateRow), for: .touchUpInside)
        locationRowView.addTarget(self, action: #selector(didTapLocationRow), for: .touchUpInside)
    }

    @objc private func didTapCategoryRow() {
        onTapCategory?()
    }

    @objc private func didTapItemStateRow() {
        onTapItemState?()
    }

    @objc private func didTapLocationRow() {
        onTapLocation?()
    }

    private func configureDefaultValues() {
        configureOptionValues(category: nil, itemState: nil, location: nil)
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }


        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }

        memoCardView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(104)
        }

        purchaseDateCardView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }

        expireDateCardView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }

        [categoryRowView, itemStateRowView, locationRowView].forEach { row in
            row.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
}

