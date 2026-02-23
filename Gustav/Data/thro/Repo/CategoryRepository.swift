//
//  CategoryRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation

final class CategoryRepository: CategoryRepositoryProtocol {
    let dataSource: CategoryDataSourceProtocol
    
    init(dataSource remote: CategoryDataSourceProtocol) {
        self.dataSource = remote
    }
    
    func fetchCategories(workspaceId: UUID) async -> DomainResult<[Category]> {
        await dataSource.fetchCategories(workspaceId: workspaceId).toDomainResult()
    }
    
    func fetchCategory(id: UUID) async -> DomainResult<Category> {
        await dataSource.fetchCategory(id: id).toDomainResult()
    }
    
    func createCategory(category: Category) async -> DomainResult<Category> {
        await dataSource.createCategory(category: category).toDomainResult()
    }
    
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void> {
        await dataSource.updateCategory(id: id, category: category).toDomainResult()
    }
    
    func deleteCategory(id: UUID) async -> DomainResult<Void> {
        await dataSource.deleteCategory(id: id).toDomainResult()
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await dataSource.reorderCategories(workspaceId: workspaceId, order: order).toDomainResult()
    }
    
}
