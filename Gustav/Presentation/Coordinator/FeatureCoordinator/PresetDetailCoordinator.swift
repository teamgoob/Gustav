//
//  PresetDetailCoordinator.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

final class PresetDetailCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let container: PresetDetailDIContainer
    private let context: PresetDetailContext
    
    var onFinish: (() -> Void)?
    
    init(
        navigationController: UINavigationController,
        container: PresetDetailDIContainer,
        context: PresetDetailContext
    ) {
        self.navigationController = navigationController
        self.container = container
        self.context = context
    }
    
    func start() {
        let viewController = container.makePresetDetailViewController(context: context)
        
        viewController.onRoute = { [weak self] route in
            self?.handle(route)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

private extension PresetDetailCoordinator {
    func handle(_ route: PresetDetailViewModel.Route) {
        switch route {
        case .showMoreMenu:
            showMoreMenu()
            
        case .showOptionPopup,
             .showSaveFailureAlert:
            break
            
        case .pop:
            navigationController.popViewController(animated: true)
            onFinish?()
        }
    }
    
    func showMoreMenu() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.barButtonItem = currentViewController?.navigationItem.rightBarButtonItem
        }
        
        currentViewController?.present(alert, animated: true)
    }
    
    var currentViewController: UIViewController? {
        navigationController.topViewController
    }
}
