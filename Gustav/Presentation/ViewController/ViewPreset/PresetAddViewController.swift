//
//  PresetAddViewController.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

final class PresetAddViewController: UIViewController {
    
    // MARK: - Callback
    var onBack: (() -> Void)?
    var onSaveSuccess: (() -> Void)?
    
    // MARK: - Properties
    private let contentView = PresetAddView()
    private let viewModel: PresetAddViewModel
    private lazy var saveButton = UIBarButtonItem(
        title: "Save",
        style: .prominent,
        target: self,
        action: #selector(didTapSaveButton)
    )
    
    // MARK: - Init
    init(viewModel: PresetAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindViewModel()
        bindActions()
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension PresetAddViewController {
    func setupNavigationBar() {
        title = "Add Preset"
        navigationItem.largeTitleDisplayMode = .always
        applySubtitle("Workspace Name")
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
    
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            guard let self else { return }
            self.applySubtitle(output.workspaceName)
            
            self.contentView.configure(
                name: output.name,
                viewType: output.viewType,
                sortingOption: output.sortingOption,
                sortingOrder: output.sortingOrder,
                category: output.category,
                location: output.location,
                itemStatus: output.itemStatus
            )
            
            self.saveButton.isEnabled = output.isSaveEnabled
            self.navigationItem.rightBarButtonItem?.isEnabled = output.isSaveEnabled
        }
        
        viewModel.onFilterMenuChanged = { [weak self] menuInfo in
            self?.updateFilterMenu(menuInfo)
        }
        
        viewModel.onNavigation = { [weak self] route in
            guard let self else { return }
            
            switch route {
            case .pop:
                self.onBack?()
                
            case .showValidationAlert(let message):
                self.presentAlert(message: message)
                
            case .showSaveFailureAlert(let message):
                self.presentAlert(message: message)
                
            case .showSaveSuccess:
                self.onSaveSuccess?()
            }
        }
    }
    
    func bindActions() {
        bindNameInput()
    }
    
    func bindNameInput() {
        contentView.nameCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.didChangeName(text))
        }
    }
    
    func updateFilterMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) {
        contentView.viewTypeRow.setMenuEnabled(true)
        contentView.viewTypeRow.menu = makeViewTypeMenu(menuInfo)

        contentView.sortByRow.setMenuEnabled(true)
        contentView.sortByRow.menu = makeSortByMenu(menuInfo)

        contentView.sortOrderRow.setMenuEnabled(true)
        contentView.sortOrderRow.menu = makeSortOrderMenu(menuInfo)

        contentView.categoryRow.setMenuEnabled(true)
        contentView.categoryRow.menu = makeCategoryMenu(menuInfo)

        contentView.locationRow.setMenuEnabled(true)
        contentView.locationRow.menu = makeLocationMenu(menuInfo)

        contentView.itemStatusRow.setMenuEnabled(true)
        contentView.itemStatusRow.menu = makeItemStatusMenu(menuInfo)
    }
    
    func makeCategoryMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.categoryFilters.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentCategoryID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectCategoryFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no category.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Category",
            attributes: menuInfo.currentCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.clearCategorySelection()
        }

        let categoryGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [categoryGroup, clearGroup])
    }

    func makeLocationMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.locationFilters.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentLocationID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectLocationFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no location.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Location",
            attributes: menuInfo.currentLocationID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.clearLocationSelection()
        }

        let locationGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [locationGroup, clearGroup])
    }

    func makeItemStatusMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.itemStateFilters.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentItemStateID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectItemStateFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no Item State.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Item State",
            attributes: menuInfo.currentItemStateID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.clearItemStatusSelection()
        }

        let itemStateGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [itemStateGroup, clearGroup])
    }

    func clearCategorySelection() {
        viewModel.action(.selectCategoryFilter(nil))
    }

    func clearLocationSelection() {
        viewModel.action(.selectLocationFilter(nil))
    }

    func clearItemStatusSelection() {
        viewModel.action(.selectItemStateFilter(nil))
    }
}

// MARK: - Action
private extension PresetAddViewController {
    func makeViewTypeMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        let actions = menuInfo.viewTypeOptions.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentViewType == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectViewType(option.id))
            }
        }

        return UIMenu(children: actions)
    }

    func makeSortByMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        let actions = menuInfo.sortOptions.map { option in
            UIAction(
                title: option.toText(),
                state: option.sortingOptionCase == menuInfo.currentSortOption?.sortingOptionCase ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectSortOption(option))
            }
        }
        let clearAction = UIAction(
            title: "Clear Sort By",
            attributes: menuInfo.currentSortOption == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.clearSortOption)
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    func makeSortOrderMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        let referenceSortOption = menuInfo.currentSortOption ?? .name(order: .ascending)
        let ascending = UIAction(
            title: referenceSortOption.orderToText(isAscending: true),
            attributes: menuInfo.currentSortOption == nil ? [.disabled] : [],
            state: menuInfo.currentSortOption?.order == .ascending ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.action(.selectSortOrder(.ascending))
        }
        let descending = UIAction(
            title: referenceSortOption.orderToText(isAscending: false),
            attributes: menuInfo.currentSortOption == nil ? [.disabled] : [],
            state: menuInfo.currentSortOption?.order == .descending ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.action(.selectSortOrder(.descending))
        }
        let clearAction = UIAction(
            title: "Clear Sort Order",
            attributes: menuInfo.currentSortOption == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.clearSortOrder)
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: [ascending, descending]),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    @objc func didTapBackButton() {
        viewModel.action(.didTapBack)
    }
    
    @objc func didTapSaveButton() {
        viewModel.action(.didTapSave)
    }
}

// MARK: - Alert
private extension PresetAddViewController {
    func presentAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
