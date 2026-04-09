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

        navigationController.pushViewController(viewController, animated: true)
    }
}
