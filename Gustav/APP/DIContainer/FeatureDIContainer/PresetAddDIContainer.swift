//
//  PresetAddDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import Foundation

final class PresetAddDIContainer {

    // MARK: - Properties
    private let appDIContainer: AppDIContainer

    // MARK: - Init
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

// MARK: - ViewModel Builder
extension PresetAddDIContainer {
    func makePresetAddViewModel(context: PresetAddContext) -> PresetAddViewModel {
        return PresetAddViewModel(
            context: context,
            viewPresetUsecase: appDIContainer.viewPresetUsecase,
            workspaceContextUsecase: appDIContainer.workspaceContextUsecase
        )
    }
}

// MARK: - Child DIContainer Builder
extension PresetAddDIContainer {
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
