//
//  PresetDetailViewController.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit

// MARK: - PresetDetailViewController
final class PresetDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let rootView = PresetDetailView()
    private let viewModel: PresetDetailViewModel
    
    // Coordinator 연결용
    var onRoute: ((PresetDetailViewModel.Route) -> Void)?
    
    // MARK: - Init
    init(viewModel: PresetDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        setupNavigation()
        bindViewModel()
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension PresetDetailViewController {
    
    func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = ""
        applySubtitle("Workspace Name")

        // 이전 버튼
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )

        // ellipsis 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTapMore)
        )
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
            self?.apply(output)
        }
        
        viewModel.onFilterMenuChanged = { [weak self] menuInfo in
            self?.updateFilterMenu(menuInfo)
        }
        
        viewModel.onNavigation = { [weak self] route in
            self?.handleRoute(route)
        }
    }
}

// MARK: - Render
private extension PresetDetailViewController {
    
    func apply(_ output: PresetDetailViewModel.Output) {
        navigationItem.title = output.title
        applySubtitle(output.workspaceName)

        rootView.configure(
            viewType: output.viewType,
            sortingOption: output.sortingOption,
            sortingOrder: output.sortingOrder,
            category: output.category,
            location: output.location,
            itemStatus: output.itemStatus
        )
    }
    
    func updateFilterMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) {
        rootView.viewTypeRow.setMenuEnabled(true)
        rootView.viewTypeRow.menu = makeViewTypeMenu(menuInfo)
        
        rootView.sortByRow.setMenuEnabled(true)
        rootView.sortByRow.menu = makeSortByMenu(menuInfo)
        
        rootView.sortOrderRow.setMenuEnabled(true)
        rootView.sortOrderRow.menu = makeSortOrderMenu(menuInfo)
        
        rootView.categoryRow.setMenuEnabled(true)
        rootView.categoryRow.menu = makeCategoryMenu(menuInfo)
        
        rootView.locationRow.setMenuEnabled(true)
        rootView.locationRow.menu = makeLocationMenu(menuInfo)
        
        rootView.itemStatusRow.setMenuEnabled(true)
        rootView.itemStatusRow.menu = makeItemStatusMenu(menuInfo)
    }

    func handleRoute(_ route: PresetDetailViewModel.Route) {
        switch route {
        case .showMoreMenu:
            onRoute?(route)
        case .pop:
            onRoute?(route)
        case .showSaveFailureAlert(let message):
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - Actions
private extension PresetDetailViewController {
    func makeViewTypeMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) -> UIMenu {
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
    
    func makeSortByMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) -> UIMenu {
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
    
    func makeSortOrderMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) -> UIMenu {
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
    
    func makeCategoryMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.categoryFilters.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentCategoryID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectCategoryFilter(option.id))
            }
        }
        
        if actions.isEmpty {
            actions = [UIAction(title: "There's no category.", attributes: .disabled) { _ in }]
        }
        
        let clearAction = UIAction(
            title: "Clear Category",
            attributes: menuInfo.currentCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectCategoryFilter(nil))
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
    
    func makeLocationMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.locationFilters.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentLocationID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectLocationFilter(option.id))
            }
        }
        
        if actions.isEmpty {
            actions = [UIAction(title: "There's no location.", attributes: .disabled) { _ in }]
        }
        
        let clearAction = UIAction(
            title: "Clear Location",
            attributes: menuInfo.currentLocationID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectLocationFilter(nil))
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
    
    func makeItemStatusMenu(_ menuInfo: PresetDetailViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.itemStateFilters.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentItemStateID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectItemStateFilter(option.id))
            }
        }
        
        if actions.isEmpty {
            actions = [UIAction(title: "There's no Item State.", attributes: .disabled) { _ in }]
        }
        
        let clearAction = UIAction(
            title: "Clear Item State",
            attributes: menuInfo.currentItemStateID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectItemStateFilter(nil))
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    @objc func didTapBack() {
        viewModel.action(.didTapBack)
    }

    @objc func didTapMore() {
        viewModel.action(.didTapMore)
    }
}
