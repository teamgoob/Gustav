//
//  CategoryRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation

final class CategoryRepository: CategoryRepositoryProtocol {
    
    
    private let dataSource: CategoryDataSourceProtocol
    private let cache: CategoryCache
    
    init(dataSource remote: CategoryDataSourceProtocol, cache: CategoryCache) {
        self.dataSource = remote
        self.cache = cache
    }
    
    func fetchCategories(workspaceId: UUID) async -> DomainResult<[Category]> {
        let cache = await self.cache.getAll(for: workspaceId)
        if !cache.isEmpty {
            return .success(cache)
        }
        switch await dataSource.fetchCategories(workspaceId: workspaceId).toDomainResult() {
        case .success(let categories):
            await self.cache.save(categories: categories, for: workspaceId)
            return .success(categories)
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    func fetchCategory(id: UUID, workspaceId: UUID) async -> DomainResult<Category> {
        if let cache = await self.cache.get(id: id, workspaceId: workspaceId) {
            return .success(cache)
        }
        
        switch await dataSource.fetchCategory(id: id).toDomainResult() {
        case .success(let category):
            await self.cache.insert(category)
            return .success(category)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createCategory(category: Category) async -> DomainResult<Category> {
        switch await dataSource.createCategory(category: category).toDomainResult() {
        case .success(let newCategory):
            await self.cache.insert(newCategory)
            return .success(newCategory)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void> {
        let result = await dataSource.updateCategory(id: id, category: category).toDomainResult()
        if case .success = result {
            await cache.update(category)
        }
        return result
    }
    
    func deleteCategory(id: UUID, workspaceId: UUID) async -> DomainResult<Void> {
        let result = await dataSource.deleteCategory(id: id).toDomainResult()
        if case .success = result {
            await cache.remove(id: id, workspaceId: workspaceId )
        }
        return result
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        let result = await dataSource.reorderCategories(workspaceId: workspaceId, order: order).toDomainResult()
        if case .success = result {
            await cache.updateOrder(workspaceId: workspaceId, order: order)
        }
        return result 
    }
    
}
