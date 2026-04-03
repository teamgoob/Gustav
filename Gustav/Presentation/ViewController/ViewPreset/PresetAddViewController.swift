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
    var onShowOptionPopup: ((PresetAddViewModel.OptionPopupRoute, @escaping (OptionPopupItem) -> Void) -> Void)?
    
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
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
    }
    
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            guard let self else { return }
            
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
        
        viewModel.onNavigation = { [weak self] route in
            guard let self else { return }
            
            switch route {
            case .showOptionPopup(let popupRoute):
                self.handleOptionPopupRoute(popupRoute)
                
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
        bindRowActions()
    }
    
    func bindNameInput() {
        contentView.nameCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.didChangeName(text))
        }
    }
    
    func bindRowActions() {
        contentView.viewTypeRow.addTapAction { [weak self] in
            self?.viewModel.action(.didTapViewType)
        }
        
        contentView.sortByRow.addTapAction { [weak self] in
            self?.viewModel.action(.didTapSortBy)
        }
        
        contentView.sortOrderRow.addTapAction { [weak self] in
            self?.viewModel.action(.didTapSortOrder)
        }
        
        contentView.categoryRow.addTapAction { [weak self] in
            self?.viewModel.action(.didTapCategory)
        }
        
        contentView.locationRow.addTapAction { [weak self] in
            self?.viewModel.action(.didTapLocation)
        }
        
        contentView.itemStatusRow.addTapAction { [weak self] in
            self?.viewModel.action(.didTapItemStatus)
        }
    }
}

// MARK: - Action
private extension PresetAddViewController {
    @objc func didTapBackButton() {
        viewModel.action(.didTapBack)
    }
    
    @objc func didTapSaveButton() {
        viewModel.action(.didTapSave)
    }
}

// MARK: - Route Handling
private extension PresetAddViewController {
    func handleOptionPopupRoute(_ route: PresetAddViewModel.OptionPopupRoute) {
        onShowOptionPopup?(route) { [weak self] selectedItem in
            guard let self else { return }
            self.handleSelectedItem(selectedItem, title: route.title)
        }
    }
    
    func handleSelectedItem(_ item: OptionPopupItem, title: String) {
        switch title {
        case "View Type":
            viewModel.action(.didSelectViewType(item.id))
            
        case "Sort By":
            viewModel.action(.didSelectSortBy(item.id))
            
        case "Sort Order":
            viewModel.action(.didSelectSortOrder(item.id))
            
        case "Category":
            guard let id = UUID(uuidString: item.id) else { return }
            viewModel.action(.didSelectCategory(id))
            
        case "Location":
            guard let id = UUID(uuidString: item.id) else { return }
            viewModel.action(.didSelectLocation(id))
            
        case "Item State":
            guard let id = UUID(uuidString: item.id) else { return }
            viewModel.action(.didSelectItemStatus(id))
            
        default:
            break
        }
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

// MARK: - Local UI Binding Helpers
private final class TapGestureTarget: NSObject {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    @objc func didTap() {
        action()
    }
}
private var tapGestureTargetKey: UInt8 = 0

private extension UIView {
    func addTapAction(_ action: @escaping () -> Void) {
        let target = TapGestureTarget(action: action)
        let gesture = UITapGestureRecognizer(target: target, action: #selector(TapGestureTarget.didTap))
        isUserInteractionEnabled = true
        addGestureRecognizer(gesture)
        objc_setAssociatedObject(self, &tapGestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
