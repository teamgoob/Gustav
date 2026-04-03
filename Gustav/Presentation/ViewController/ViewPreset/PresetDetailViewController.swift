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
    private lazy var dropdownManager = DropdownOverlayManager(hostViewController: self)
    
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
        bindActions()
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension PresetDetailViewController {
    
    func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = ""

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
    
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        
        viewModel.onNavigation = { [weak self] route in
            self?.handleRoute(route)
        }
    }
    
    func bindActions() {
        rootView.viewTypeRow.addTarget(self, action: #selector(didTapViewType), for: .touchUpInside)
        rootView.sortByRow.addTarget(self, action: #selector(didTapSortBy), for: .touchUpInside)
        rootView.sortOrderRow.addTarget(self, action: #selector(didTapSortOrder), for: .touchUpInside)
        rootView.categoryRow.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        rootView.locationRow.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        rootView.itemStatusRow.addTarget(self, action: #selector(didTapItemStatus), for: .touchUpInside)
    }
}

// MARK: - Render
private extension PresetDetailViewController {
    
    func apply(_ output: PresetDetailViewModel.Output) {
        navigationItem.title = output.title

        rootView.configure(
            viewType: output.viewType,
            sortingOption: output.sortingOption,
            sortingOrder: output.sortingOrder,
            category: output.category,
            location: output.location,
            itemStatus: output.itemStatus
        )
    }

    func handleRoute(_ route: PresetDetailViewModel.Route) {
        switch route {
        case .showOptionPopup(let popupRoute):
            showOptionPopup(popupRoute)
        case .showMoreMenu:
            dropdownManager.dismiss(animated: false)
            onRoute?(route)
        case .pop:
            dropdownManager.dismiss(animated: false)
            navigationController?.popViewController(animated: true)
        case .showSaveFailureAlert(let message):
            dropdownManager.dismiss(animated: false)
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func showOptionPopup(_ route: PresetDetailViewModel.OptionPopupRoute) {
        let popupView = OptionPopupView(
            items: route.items,
            selectedItemID: route.selectedID
        )
        
        popupView.onSelectItem = { [weak self] selectedItem in
            guard let self else { return }
            self.dropdownManager.dismiss(animated: true)
            
            switch route.title {
            case "View Type":
                self.viewModel.action(.didSelectViewType(selectedItem.id))
                
            case "Sort By":
                self.viewModel.action(.didSelectSortBy(selectedItem.id))
                
            case "Sort Order":
                self.viewModel.action(.didSelectSortOrder(selectedItem.id))
                
            case "Category":
                guard let id = UUID(uuidString: selectedItem.id) else { return }
                self.viewModel.action(.didSelectCategory(id))
                
            case "Location":
                guard let id = UUID(uuidString: selectedItem.id) else { return }
                self.viewModel.action(.didSelectLocation(id))
                
            case "Item State":
                guard let id = UUID(uuidString: selectedItem.id) else { return }
                self.viewModel.action(.didSelectItemStatus(id))
                
            default:
                break
            }
        }
        
        dropdownManager.present(
            contentView: popupView,
            from: anchorView(for: route.title),
            preferredSize: preferredPopupSize(for: route.items.count)
        )
    }
    
    func anchorView(for title: String) -> UIView {
        switch title {
        case "View Type":
            return rootView.viewTypeRow
        case "Sort By":
            return rootView.sortByRow
        case "Sort Order":
            return rootView.sortOrderRow
        case "Category":
            return rootView.categoryRow
        case "Location":
            return rootView.locationRow
        case "Item State":
            return rootView.itemStatusRow
        default:
            return rootView.viewTypeRow
        }
    }
    
    func preferredPopupSize(for itemCount: Int) -> CGSize {
        let rowHeight: CGFloat = 56
        let verticalPadding: CGFloat = 16
        let maxVisibleRows = min(max(itemCount, 1), 5)
        let height = CGFloat(maxVisibleRows) * rowHeight + verticalPadding
        return CGSize(width: rootView.bounds.width - 40, height: height)
    }
}

// MARK: - Actions
private extension PresetDetailViewController {

    @objc func didTapDropdownOverlay() {
        dropdownManager.dismiss(animated: true)
    }
    
    @objc func didTapViewType() {
        viewModel.action(.didTapViewType)
    }
    
    @objc func didTapSortBy() {
        viewModel.action(.didTapSortBy)
    }
    
    @objc func didTapSortOrder() {
        viewModel.action(.didTapSortOrder)
    }
    
    @objc func didTapCategory() {
        viewModel.action(.didTapCategory)
    }
    
    @objc func didTapLocation() {
        viewModel.action(.didTapLocation)
    }
    
    @objc func didTapItemStatus() {
        viewModel.action(.didTapItemStatus)
    }
    
    @objc func didTapBack() {
        viewModel.action(.didTapBack)
    }

    @objc func didTapMore() {
        viewModel.action(.didTapMore)
    }
}
