//
//  PresetAddDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

final class PresetAddDIContainer {

    // MARK: - Properties
    private let appDIContainer: AppDIContainer

    // MARK: - Init
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

// MARK: - Context Builder
extension PresetAddDIContainer {
    func makePresetAddContext(workspaceId: UUID) async -> PresetAddContext {
        async let categoriesResult = appDIContainer.categoryUsecase.fetchCategories(workspaceId: workspaceId)
        async let locationsResult = appDIContainer.locationUsecase.fetchLocations(workspaceId: workspaceId)
        async let itemStatesResult = appDIContainer.itemStateUsecase.fetchItemStates(workspaceId: workspaceId)

        let categoryNameByID: [UUID: String]
        switch await categoriesResult {
        case .success(let categories):
            categoryNameByID = Dictionary(
                uniqueKeysWithValues: categories.map { ($0.id, $0.name) }
            )
        case .failure:
            categoryNameByID = [:]
        }

        let locationNameByID: [UUID: String]
        switch await locationsResult {
        case .success(let locations):
            locationNameByID = Dictionary(
                uniqueKeysWithValues: locations.map { ($0.id, $0.name) }
            )
        case .failure:
            locationNameByID = [:]
        }

        let itemStateNameByID: [UUID: String]
        switch await itemStatesResult {
        case .success(let itemStates):
            itemStateNameByID = Dictionary(
                uniqueKeysWithValues: itemStates.map { ($0.id, $0.name) }
            )
        case .failure:
            itemStateNameByID = [:]
        }

        return PresetAddContext(
            workspaceId: workspaceId,
            categoryNameByID: categoryNameByID,
            locationNameByID: locationNameByID,
            itemStateNameByID: itemStateNameByID
        )
    }
}

// MARK: - ViewModel Builder
extension PresetAddDIContainer {
    func makePresetAddViewModel(workspaceId: UUID) async -> PresetAddViewModel {
        let context = await makePresetAddContext(workspaceId: workspaceId)

        return PresetAddViewModel(
            context: context,
            viewPresetUsecase: appDIContainer.viewPresetUsecase
        )
    }
}

// MARK: - Coordinator Builder
extension PresetAddDIContainer {
    func makePresetAddCoordinator(
        navigationController: UINavigationController,
        workspaceId: UUID
    ) async -> PresetAddCoordinator {
        let viewModel = await makePresetAddViewModel(workspaceId: workspaceId)

        return PresetAddCoordinator(
            navigationController: navigationController,
            viewModel: viewModel
        )
    }
}
