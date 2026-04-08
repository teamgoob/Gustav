//
//  ItemAddDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//
import Foundation

/// Item Add 화면에서 필요한 객체를 생성하는 DIContainer
final class ItemAddDIContainer {
    
    // MARK: - Properties
    
    private let appDIContainer: AppDIContainer
    
    // MARK: - Init
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - ViewModel Builder
    
    /// ItemAddViewModel 생성
    func makeItemAddViewModel(context: ItemAddContext) -> ItemAddViewModel {
        ItemAddViewModel(
            context: context,
            itemUseCase: appDIContainer.itemUsecase
        )
    }
    
    func makeItemAddContext(workspaceContext: WorkspaceContext) -> ItemAddContext {
        ItemAddContext(
            workspaceId: workspaceContext.workspace.id,
            workspaceContext: workspaceContext
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
