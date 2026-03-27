//
//  CategoryListDIContainer.swift
//  Gustav
//
//  Created by 박선린 on 3/23/26.
//
import Foundation

final class ItemStateListDIContainer {
    private let appContainer: AppDIContainer

    init(appContainer: AppDIContainer) {
        self.appContainer = appContainer
    }
    
    // MARK: - ViewModel Builder
    func makeItemStateListViewModel(selectedWorkspaceId: UUID) -> ItemStateListViewModel {
        ItemStateListViewModel(itemStateUsecase: appContainer.itemStateUsecase, selectedWorkspaceId: selectedWorkspaceId)
    }
    
    func makeCategoryDetailViewModel(itemState: ItemState) -> ItemStateDetailViewModel {
        ItemStateDetailViewModel(
            itemState: itemState,
            itemStateUsecase: appContainer.itemStateUsecase,
            itemQueryUsecase: appContainer.itemQueryUsecase
        )
    }
}
