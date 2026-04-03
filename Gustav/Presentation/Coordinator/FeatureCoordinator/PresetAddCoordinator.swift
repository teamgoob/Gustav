//
//  PresetAddCoordinator.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

final class PresetAddCoordinator: Coordinator {
    
    // MARK: - Properties
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let viewModel: PresetAddViewModel
    
    var onFinish: ((Coordinator) -> Void)?
    
    // MARK: - Init
    init(
        navigationController: UINavigationController,
        viewModel: PresetAddViewModel
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    // MARK: - Public
    func start() {
        showPresetAdd()
    }
    
    func finish() {
        onFinish?(self)
    }
}

// MARK: - Private
private extension PresetAddCoordinator {
    func showPresetAdd() {
        let viewController = PresetAddViewController(viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
            self.finish()
        }
        
        viewController.onSaveSuccess = { [weak self] in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
            self.finish()
        }
        
        viewController.onShowOptionPopup = { [weak self, weak viewController] route, selectionHandler in
            guard let self, let viewController else { return }
            self.presentOptionPopup(
                from: viewController,
                route: route,
                selectionHandler: selectionHandler
            )
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentOptionPopup(
        from viewController: UIViewController,
        route: PresetAddViewModel.OptionPopupRoute,
        selectionHandler: @escaping (OptionPopupItem) -> Void
    ) {
        let alertController = UIAlertController(
            title: route.title,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        route.items.forEach { item in
            let isSelected = item.id == route.selectedID
            let title = isSelected ? "✓ \(item.title)" : item.title
            
            let action = UIAlertAction(title: title, style: .default) { _ in
                selectionHandler(item)
            }
            
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = viewController.view
            popoverPresentationController.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 1,
                height: 1
            )
            popoverPresentationController.permittedArrowDirections = []
        }
        
        viewController.present(alertController, animated: true)
    }
}
