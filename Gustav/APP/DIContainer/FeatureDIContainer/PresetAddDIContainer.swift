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
    func makePresetAddViewModel(workspaceId: UUID) async -> PresetAddViewModel {
        let result = await appDIContainer.workspaceContextUsecase.fetchContext(workspaceId: workspaceId)

        let context: PresetAddContext
        switch result {
        case .success(let workspaceContext):
            context = makePresetAddContext(from: workspaceContext, workspaceId: workspaceId)
        case .failure:
            context = PresetAddContext(
                workspaceId: workspaceId,
                categoryNameByID: [:],
                locationNameByID: [:],
                itemStateNameByID: [:]
            )
        }

        return PresetAddViewModel(
            context: context,
            viewPresetUsecase: appDIContainer.viewPresetUsecase
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

// MARK: - Private Helper
private extension PresetAddDIContainer {
    func makePresetAddContext(
        from workspaceContext: WorkspaceContext,
        workspaceId: UUID
    ) -> PresetAddContext {
        let categoryNameByID = Dictionary(
            uniqueKeysWithValues: workspaceContext.categories.map { ($0.id, $0.name) }
        )

        let locationNameByID = Dictionary(
            uniqueKeysWithValues: workspaceContext.locations.map { ($0.id, $0.name) }
        )

        let itemStateNameByID = Dictionary(
            uniqueKeysWithValues: workspaceContext.states.map { ($0.id, $0.name) }
        )

        return PresetAddContext(
            workspaceId: workspaceId,
            categoryNameByID: categoryNameByID,
            locationNameByID: locationNameByID,
            itemStateNameByID: itemStateNameByID
        )
    }
}
