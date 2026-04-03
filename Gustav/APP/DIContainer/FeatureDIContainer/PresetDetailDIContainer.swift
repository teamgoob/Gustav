//
//  PresetDetailDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

// MARK: - PresetDetailDIContainer
final class PresetDetailDIContainer {

    private let appDIContainer: AppDIContainer

    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - ViewModel Builder
    func makePresetDetailViewModel(context: PresetDetailContext) -> PresetDetailViewModel {
        PresetDetailViewModel(
            context: context,
            viewPresetUsecase: appDIContainer.viewPresetUsecase
        )
    }
    
    // MARK: - ViewController Builder
    func makePresetDetailViewController(
        context: PresetDetailContext
    ) -> PresetDetailViewController {
        let viewModel = makePresetDetailViewModel(context: context)
        return PresetDetailViewController(viewModel: viewModel)
    }
    
}


// MARK: - Coordinator Builder
extension PresetDetailDIContainer {
    func makePresetDetailCoordinator(
        navigationController: UINavigationController,
        context: PresetDetailContext
    ) -> PresetDetailCoordinator {
        PresetDetailCoordinator(
            navigationController: navigationController,
            container: self,
            context: context
        )
    }
}
