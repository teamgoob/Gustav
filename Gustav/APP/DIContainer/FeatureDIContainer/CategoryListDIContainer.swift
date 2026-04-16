//
//  CategoryListDIContainer.swift
//  Gustav
//
//  Created by 박선린 on 3/23/26.
//
import Foundation

final class CategoryListDIContainer {
    private let appContainer: AppDIContainer

    init(appContainer: AppDIContainer) {
        self.appContainer = appContainer
    }
    
    // MARK: - ViewModel Builder
    func makeCategoryListViewModel(selectedWorkspaceId: UUID) -> CategoryListViewModel {
        CategoryListViewModel(categoryUsecase: appContainer.categoryUsecase, selectedWorkspaceId: selectedWorkspaceId)
    }
    
    func makeCategoryDetailViewModel(category: Category) -> CategoryDetailViewModel {
        CategoryDetailViewModel(
            category: category,
            categoryUsecase: appContainer.categoryUsecase,
            itemQueryUsecase: appContainer.itemQueryUsecase
        )
    }
}
