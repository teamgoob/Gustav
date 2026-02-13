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
    
    func fetchCategories(workspaceId: UUID) async -> RepositoryResult<[Category]> {
        fatalError("Not implemented")
    }
    
    func fetchCategory(id: UUID) async -> RepositoryResult<Category> {
        fatalError("Not implemented")
    }
    
    func createCategory(workspaceId: UUID, parentId: UUID?, name: String, color: TagColor) async -> RepositoryResult<Category> {
        fatalError("Not implemented")
    }
    
    func updateCategory(id: UUID, category: Category) async -> RepositoryResult<Void> {
        fatalError("Not implemented")
    }
    
    func deleteCategory(id: UUID) async -> RepositoryResult<Void> {
        fatalError("Not implemented")
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        fatalError("Not implemented")
    }
    
}
