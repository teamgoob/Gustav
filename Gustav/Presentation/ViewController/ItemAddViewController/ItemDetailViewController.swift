//
//  ItemDetailViewController.swift
//  Gustav
//
//

import UIKit
import SnapKit

final class ItemDetailViewController: UIViewController {

    // MARK: - Properties

    private let rootView: ItemDetailView
    private let viewModel: ItemDetailViewModel

    var onRoute: ((ItemDetailViewModel.Route) -> Void)?

    // MARK: - Init

    init(viewModel: ItemDetailViewModel) {
        self.viewModel = viewModel
        self.rootView = ItemDetailView(content: viewModel.initialContent)
        super.init(nibName: nil, bundle: nil)
        setupNavigation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
        bindViewModel()
        bindInputs()
        viewModel.action(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.sizeToFit()
        viewModel.action(.viewDidAppear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent {
            onRoute?(.dismiss)
        }
    }
}

// MARK: - Navigation

private extension ItemDetailViewController {
    func setupNavigation() {
        navigationItem.title = "Item Detail"
        navigationItem.largeTitleDisplayMode = .always
        applySubtitle("Workspace Name")

        let saveButton = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(didTapSave)
        )

        saveButton.isEnabled = true
        navigationItem.rightBarButtonItem = saveButton
    }

    func applySubtitle(_ text: String) {
        var largeSubtitle = AttributedString(text)
        largeSubtitle.font = Fonts.accent
        largeSubtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = largeSubtitle

        var compactSubtitle = AttributedString(text)
        compactSubtitle.font = Fonts.additional
        compactSubtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.attributedSubtitle = compactSubtitle
    }
}

// MARK: - Bind ViewModel

private extension ItemDetailViewController {
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }

        viewModel.onNavigation = { [weak self] route in
            self?.handleRoute(route)
        }
    }
}

// MARK: - Bind Input Components

private extension ItemDetailViewController {
    func bindInputs() {
        bindNameInput()
        bindPriceQuantityInput()
        bindPurchasePlaceInput()
        bindMemoInput()
        bindPurchaseDateInput()
        bindExpireDateInput()
    }

    func bindNameInput() {
        rootView.itemNameCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.changeName(text))
        }

        rootView.itemNameCardView.onSecondTextChanged = { [weak self] text in
            self?.viewModel.action(.changeDetailName(text))
        }
    }

    func bindPriceQuantityInput() {
        rootView.priceQuantityCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.changePrice(text))
        }

        rootView.priceQuantityCardView.onSecondTextChanged = { [weak self] text in
            self?.viewModel.action(.changeQuantity(text))
        }
    }

    func bindPurchasePlaceInput() {
        rootView.purchasePlaceCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.changePurchasePlace(text))
        }
    }

    func bindMemoInput() {
        rootView.memoCardView.onTextChanged = { [weak self] text in
            self?.viewModel.action(.changeMemo(text))
        }
    }

    func bindPurchaseDateInput() {
        rootView.purchaseDateCardView.onSwitchChanged = { [weak self] isOn in
            self?.viewModel.action(.togglePurchaseDate(isOn))
        }

        rootView.purchaseDateCardView.onDateChanged = { [weak self] date in
            self?.viewModel.action(.changePurchaseDate(date))
        }

        rootView.purchaseDateCardView.onTimeChanged = { [weak self] time in
            self?.viewModel.action(.changePurchaseTime(time))
        }
    }

    func bindExpireDateInput() {
        rootView.expireDateCardView.onSwitchChanged = { [weak self] isOn in
            self?.viewModel.action(.toggleExpireDate(isOn))
        }

        rootView.expireDateCardView.onDateChanged = { [weak self] date in
            self?.viewModel.action(.changeExpireDate(date))
        }

        rootView.expireDateCardView.onTimeChanged = { [weak self] time in
            self?.viewModel.action(.changeExpireTime(time))
        }
    }
}

// MARK: - Apply Output / Route

private extension ItemDetailViewController {
    func apply(_ output: ItemDetailViewModel.Output) {
        applySubtitle(output.workspaceName)
        navigationItem.rightBarButtonItem?.isEnabled = output.saveButtonEnabled

        if output.isSaving {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }

        rootView.configureOptionValues(
            category: output.selectedCategoryName,
            subcategory: output.selectedSubcategoryName,
            showsSubcategory: output.showsSubcategoryRow,
            itemState: output.selectedItemStateName,
            location: output.selectedLocationName
        )
        updateOptionMenus(output)

        rootView.purchaseDateCardView.setSwitchOn(output.isPurchaseDateEnabled, animated: false)
        rootView.expireDateCardView.setSwitchOn(output.isExpireDateEnabled, animated: false)
    }

    func handleRoute(_ route: ItemDetailViewModel.Route) {
        switch route {
        case .dismiss, .dismissAfterSave, .showErrorAlert:
            onRoute?(route)
        }
    }

    func updateOptionMenus(_ output: ItemDetailViewModel.Output) {
        rootView.categoryRowView.setMenuEnabled(true)
        rootView.categoryRowView.menu = makeCategoryMenu(output)

        rootView.subcategoryRowView.isHidden = !output.showsSubcategoryRow
        rootView.subcategoryRowView.setMenuEnabled(output.showsSubcategoryRow)
        rootView.subcategoryRowView.menu = output.showsSubcategoryRow ? makeSubcategoryMenu(output) : nil

        rootView.itemStateRowView.setMenuEnabled(true)
        rootView.itemStateRowView.menu = makeItemStateMenu(output)

        rootView.locationRowView.setMenuEnabled(true)
        rootView.locationRowView.menu = makeLocationMenu(output)
    }

    func makeCategoryMenu(_ output: ItemDetailViewModel.Output) -> UIMenu {
        var actions = output.availableParentCategories
            .sorted { $0.indexKey < $1.indexKey }
            .map { category in
                UIAction(
                    title: category.name,
                    image: Icons.tagColorCircle(category.color),
                    state: output.selectedParentCategoryID == category.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectParentCategory(category.id))
                }
            }

        if actions.isEmpty {
            actions = [UIAction(title: "There's no category.", attributes: .disabled) { _ in }]
        }

        let clearAction = UIAction(
            title: "Clear Category",
            attributes: output.selectedParentCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectParentCategory(nil))
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    func makeSubcategoryMenu(_ output: ItemDetailViewModel.Output) -> UIMenu {
        var actions = output.availableChildCategories
            .sorted { $0.indexKey < $1.indexKey }
            .map { category in
                UIAction(
                    title: category.name,
                    image: Icons.tagColorCircle(category.color),
                    state: output.selectedChildCategoryID == category.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectChildCategory(category.id))
                }
            }

        if actions.isEmpty {
            actions = [UIAction(title: "There's no subcategory.", attributes: .disabled) { _ in }]
        }

        let clearAction = UIAction(
            title: "Clear Subcategory",
            attributes: output.selectedChildCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectChildCategory(nil))
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    func makeItemStateMenu(_ output: ItemDetailViewModel.Output) -> UIMenu {
        var actions = output.availableItemStates
            .sorted { $0.indexKey < $1.indexKey }
            .map { itemState in
                UIAction(
                    title: itemState.name,
                    image: Icons.tagColorCircle(itemState.color),
                    state: output.selectedItemStateID == itemState.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectItemState(id: itemState.id, name: itemState.name))
                }
            }

        if actions.isEmpty {
            actions = [UIAction(title: "There's no Item State.", attributes: .disabled) { _ in }]
        }

        let clearAction = UIAction(
            title: "Clear Item State",
            attributes: output.selectedItemStateID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectItemState(id: nil, name: nil))
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    func makeLocationMenu(_ output: ItemDetailViewModel.Output) -> UIMenu {
        var actions = output.availableLocations
            .sorted { $0.indexKey < $1.indexKey }
            .map { location in
                UIAction(
                    title: location.name,
                    image: Icons.tagColorCircle(location.color),
                    state: output.selectedLocationID == location.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectLocation(id: location.id, name: location.name))
                }
            }

        if actions.isEmpty {
            actions = [UIAction(title: "There's no location.", attributes: .disabled) { _ in }]
        }

        let clearAction = UIAction(
            title: "Clear Location",
            attributes: output.selectedLocationID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectLocation(id: nil, name: nil))
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
}

// MARK: - Navigation Bar Actions

private extension ItemDetailViewController {
    @objc func didTapSave() {
        viewModel.action(.tapSave)
    }
}

// MARK: - Gesture / Keyboard

private extension ItemDetailViewController {
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
