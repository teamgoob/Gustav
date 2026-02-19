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
        var categories: [Category] = []
        do {
            let result = try await dataSource.fetchCategories(workspaceId: workspaceId).get()
            categories = result.map { $0.toEntity() }

            return .success(categories)
        } catch {
            return .failure(DomainError.unknown)    // 임시
        }
    }
    
    func fetchCategory(id: UUID) async -> DomainResult<Category> {
        do {
            let result = try await dataSource.fetchCategory(id: id).get()
            return .success(result.toEntity())
        } catch {
            return .failure(DomainError.entityNotFound)    // 임시
        }
    }
    
    func createCategory(workspaceId: UUID, parentId: UUID?, name: String, color: TagColor) async -> DomainResult<Category> {
        let dto = CategoryDTO(
            id: UUID(),
            workspaceId: workspaceId,
            parentId: parentId,
            indexKey: 10_000,
            name: name,
            color: color.rawValue,
            createdAt: Date().description,
            updatedAt: nil)
        do {
            let result = try await dataSource.createCategory(categoryDTO: dto).get()
            return .success(result.toEntity())
        } catch {
            return .failure(DomainError.entityNotFound)    // 임시
        }
    }
    
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void> {
        let result = await dataSource.updateCategory(id: id, dto: category.toDTO())
        return result.toDomainResult()
    }
    
    func deleteCategory(id: UUID) async -> DomainResult<Void> {
        let result = await dataSource.deleteCategory(id: id)
        return result.toDomainResult()
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        let result = await dataSource.reorderCategories(workspaceId: workspaceId, order: order)
        return result.toDomainResult()
    }
    
}
