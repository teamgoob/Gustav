//
//  ItemDetailView.swift
//  Gustav
//

import UIKit
import SnapKit
import SwiftUI

final class ItemDetailView: UIView {

    struct Content {
        let name: String?
        let detailName: String?
        let priceText: String?
        let quantityText: String?
        let memo: String?
        let purchasePlace: String?
        let purchaseDate: Date
        let purchaseTime: Date
        let isPurchaseDateEnabled: Bool
        let expireDate: Date
        let expireTime: Date
        let isExpireDateEnabled: Bool
        let category: String?
        let subcategory: String?
        let showsSubcategory: Bool
        let itemState: String?
        let location: String?

        init(
            name: String? = nil,
            detailName: String? = nil,
            priceText: String? = nil,
            quantityText: String? = nil,
            memo: String? = nil,
            purchasePlace: String? = nil,
            purchaseDate: Date = Date(),
            purchaseTime: Date = Date(),
            isPurchaseDateEnabled: Bool = false,
            expireDate: Date = Date(),
            expireTime: Date = Date(),
            isExpireDateEnabled: Bool = false,
            category: String? = nil,
            subcategory: String? = nil,
            showsSubcategory: Bool = false,
            itemState: String? = nil,
            location: String? = nil
        ) {
            self.name = name
            self.detailName = detailName
            self.priceText = priceText
            self.quantityText = quantityText
            self.memo = memo
            self.purchasePlace = purchasePlace
            self.purchaseDate = purchaseDate
            self.purchaseTime = purchaseTime
            self.isPurchaseDateEnabled = isPurchaseDateEnabled
            self.expireDate = expireDate
            self.expireTime = expireTime
            self.isExpireDateEnabled = isExpireDateEnabled
            self.category = category
            self.subcategory = subcategory
            self.showsSubcategory = showsSubcategory
            self.itemState = itemState
            self.location = location
        }
    }

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
            isOn: false
        )
    )

    let expireDateCardView = ItemAddDateCardView(
        configuration: .init(
            toggleTitle: "Purchase Expire at",
            dateTitle: "Date",
            dateText: "",
            timeText: "",
            isOn: false
        )
    )

    private let optionSectionStackView = UIStackView()
    let categoryRowView = OptionRowView()
    let subcategoryRowView = OptionRowView()
    let itemStateRowView = OptionRowView()
    let locationRowView = OptionRowView()

    // MARK: - Init

    init(content: Content? = nil) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        configureDefaultValues()

        if let content {
            configureContent(content)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configureOptionValues(
        category: String?,
        subcategory: String?,
        showsSubcategory: Bool,
        itemState: String?,
        location: String?
    ) {
        categoryRowView.configure(title: "Category", value: category ?? "none")
        subcategoryRowView.configure(title: "Subcategory", value: subcategory ?? "none")
        subcategoryRowView.isHidden = !showsSubcategory
        itemStateRowView.configure(title: "Item state", value: itemState ?? "none")
        locationRowView.configure(title: "Location", value: location ?? "none")
    }

    func configureContent(_ content: Content) {
        itemNameCardView.setFirstText(content.name)
        itemNameCardView.setSecondText(content.detailName)
        priceQuantityCardView.setFirstText(content.priceText)
        priceQuantityCardView.setSecondText(content.quantityText)
        memoCardView.text = content.memo
        purchasePlaceCardView.setFirstText(content.purchasePlace)

        purchaseDateCardView.update(
            date: content.purchaseDate,
            time: content.purchaseTime,
            isOn: content.isPurchaseDateEnabled
        )

        expireDateCardView.update(
            date: content.expireDate,
            time: content.expireTime,
            isOn: content.isExpireDateEnabled
        )

        configureOptionValues(
            category: content.category,
            subcategory: content.subcategory,
            showsSubcategory: content.showsSubcategory,
            itemState: content.itemState,
            location: content.location
        )
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = Colors.Theme.mainBackground
        subcategoryRowView.isHidden = true

        setupMainStackView()
        setupOptionSectionStackView()
        setupInputKeyboardTypes()
        setupMemoPlaceholder()

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
        optionSectionStackView.addArrangedSubview(subcategoryRowView)
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
        priceQuantityCardView.setFirstKeyboardType(.numberPad)
        priceQuantityCardView.setSecondKeyboardType(.numberPad)
    }

    private func setupMemoPlaceholder() {
        memoCardView.setPlaceholder("memo")
    }

    private func configureDefaultValues() {
        configureOptionValues(
            category: nil,
            subcategory: nil,
            showsSubcategory: false,
            itemState: nil,
            location: nil
        )
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        [categoryRowView, subcategoryRowView, itemStateRowView, locationRowView].forEach { row in
            row.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
}

#if DEBUG
private struct ItemDetailViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        ItemDetailView(
            content: .init(
                name: "MacBook Pro",
                detailName: "14-inch M4",
                priceText: "3200000",
                quantityText: "1",
                memo: "Used for work",
                purchasePlace: "Apple Store",
                isPurchaseDateEnabled: true,
                isExpireDateEnabled: true,
                category: "Electronics",
                subcategory: "Laptop",
                showsSubcategory: true,
                itemState: "In Use",
                location: "Office"
            )
        )
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    ItemDetailViewPreview()
}
#endif
