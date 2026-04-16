//
//  PresetDetailCoordinator.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

final class PresetDetailCoordinator: BaseCoordinator {
    private let container: PresetDetailDIContainer
    private let context: PresetDetailContext
    
    var onFinish: ((Coordinator) -> Void)?
    
    init(
        navigationController: UINavigationController,
        container: PresetDetailDIContainer,
        context: PresetDetailContext
    ) {
        self.container = container
        self.context = context
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Flow Start
    override func start() {
        super.start()
        showPresetDetail()
    }

    // MARK: - Flow Finish
    func finish() {
        onFinish?(self)
    }

    // MARK: - Deinit Children
    override func removeChild(_ finishedCoordinator: Coordinator) {
        super.removeChild(finishedCoordinator)
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }
}

private extension PresetDetailCoordinator {
    // Default View
    func showPresetDetail() {
        let viewModel = container.makePresetDetailViewModel(context: context)
        let viewController = PresetDetailViewController(viewModel: viewModel)
        
        viewController.onRoute = { [weak self] route in
            switch route {
            case .showErrorAlert:
                break
                
            case .pop:
                self?.navigationController.popViewController(animated: true)
                self?.finish()
            }
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
