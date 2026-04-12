//
//  PresetDetailDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import Foundation

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
            viewPresetUsecase: appDIContainer.viewPresetUsecase,
            workspaceContextUsecase: appDIContainer.workspaceContextUsecase
        )
    }
    
    // MARK: - Child DIContainer Builder
    func makeCategoryListDIContainer() -> CategoryListDIContainer {
        CategoryListDIContainer(appContainer: appDIContainer)
    }

    func makeLocationListDIContainer() -> LocationListDIContainer {
        LocationListDIContainer(appContainer: appDIContainer)
    }

    func makeItemStateListDIContainer() -> ItemStateListDIContainer {
        ItemStateListDIContainer(appContainer: appDIContainer)
    }
    
}
