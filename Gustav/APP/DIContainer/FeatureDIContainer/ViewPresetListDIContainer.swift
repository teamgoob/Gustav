//
//  ViewPresetListDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//
import Foundation
import UIKit

final class ViewPresetListDIContainer {
    private let appContainer: AppDIContainer

    init(appContainer: AppDIContainer) {
        self.appContainer = appContainer
    }

    func makeViewPresetListViewModel(workspaceId: UUID) -> ViewPresetListViewModel {
        ViewPresetListViewModel(
            viewPresetUsecase: appContainer.viewPresetUsecase,
            workspaceId: workspaceId
        )
    }

    func makeViewPresetListViewController(workspaceId: UUID) -> ViewPresetListViewController {
        let viewModel = makeViewPresetListViewModel(workspaceId: workspaceId)
        return ViewPresetListViewController(viewModel: viewModel)
    }

    func makePresetDetailDIContainer() -> PresetDetailDIContainer {
        PresetDetailDIContainer(appDIContainer: appContainer)
    }

    func makePresetAddDIContainer() -> PresetAddDIContainer {
        PresetAddDIContainer(appDIContainer: appContainer)
    }

    // MARK: - Preset Add Builder
    func makePresetAddContext(workspaceId: UUID) async throws -> PresetAddContext {
        async let categoryResult = appContainer.categoryUsecase.fetchCategories(workspaceId: workspaceId)
        async let locationResult = appContainer.locationUsecase.fetchLocations(workspaceId: workspaceId)
        async let itemStateResult = appContainer.itemStateUsecase.fetchItemStates(workspaceId: workspaceId)
        
        let categories = try await unwrapDomainResult(categoryResult)
        let locations = try await unwrapDomainResult(locationResult)
        let itemStates = try await unwrapDomainResult(itemStateResult)
        
        let categoryNameByID = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
        let locationNameByID = Dictionary(uniqueKeysWithValues: locations.map { ($0.id, $0.name) })
        let itemStateNameByID = Dictionary(uniqueKeysWithValues: itemStates.map { ($0.id, $0.name) })
        
        return PresetAddContext(
            workspaceId: workspaceId,
            categoryNameByID: categoryNameByID,
            locationNameByID: locationNameByID,
            itemStateNameByID: itemStateNameByID
        )
    }
    
    func makePresetAddViewModel(workspaceId: UUID) async throws -> PresetAddViewModel {
        let context = try await makePresetAddContext(workspaceId: workspaceId)
        
        return PresetAddViewModel(
            context: context,
            viewPresetUsecase: appContainer.viewPresetUsecase
        )
    }
    
    func makePresetAddCoordinator(
        navigationController: UINavigationController,
        workspaceId: UUID
    ) async throws -> PresetAddCoordinator {
        let viewModel = try await makePresetAddViewModel(workspaceId: workspaceId)
        
        return PresetAddCoordinator(
            navigationController: navigationController,
            viewModel: viewModel
        )
    }
    
    private func unwrapDomainResult<T>(_ result: DomainResult<T>) throws -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
