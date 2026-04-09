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
            viewPresetUsecase: appDIContainer.viewPresetUsecase
        )
    }

    func makePresetDetailContext(workspaceId: UUID, presetId: UUID) async -> PresetDetailContext {
        let presetResult = await appDIContainer.viewPresetUsecase.fetchViewPresets(workspaceId: workspaceId)
        let workspaceContextResult = await appDIContainer.workspaceContextUsecase.fetchContext(workspaceId: workspaceId)

        let fallbackPreset = ViewPreset(
            id: presetId,
            workspaceId: workspaceId,
            name: "",
            viewType: 0,
            sortingOption: .indexKey(order: .ascending),
            filters: [],
            createdAt: nil,
            updatedAt: nil
        )

        let preset: ViewPreset
        switch presetResult {
        case .success(let presets):
            preset = presets.first(where: { $0.id == presetId }) ?? fallbackPreset
        case .failure:
            preset = fallbackPreset
        }

        let categories: [Category]
        let categoryNameByID: [UUID: String]
        let locationNameByID: [UUID: String]
        let itemStateNameByID: [UUID: String]
        let workspaceName: String

        switch workspaceContextResult {
        case .success(let workspaceContext):
            workspaceName = workspaceContext.workspace.name
            categories = workspaceContext.categories
            categoryNameByID = Dictionary(uniqueKeysWithValues: workspaceContext.categories.map { ($0.id, $0.name) })
            locationNameByID = Dictionary(uniqueKeysWithValues: workspaceContext.locations.map { ($0.id, $0.name) })
            itemStateNameByID = Dictionary(uniqueKeysWithValues: workspaceContext.states.map { ($0.id, $0.name) })

        case .failure:
            workspaceName = ""
            categories = []
            categoryNameByID = [:]
            locationNameByID = [:]
            itemStateNameByID = [:]
        }

        return PresetDetailContext(
            preset: preset,
            workspaceName: workspaceName,
            categories: categories,
            categoryNameByID: categoryNameByID,
            locationNameByID: locationNameByID,
            itemStateNameByID: itemStateNameByID
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
