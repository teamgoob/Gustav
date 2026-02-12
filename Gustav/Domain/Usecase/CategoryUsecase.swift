//
//  CategoryUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 카테고리 관리 Usecase
protocol CategoryUsecaseProtocol {
    // 워크스페이스 내 카테고리 목록 조회
    // parent_id 기준 상위 / 하위 분리
    // indexKey 기준 정렬
    func fetchCategories(workspaceId: UUID) async -> DomainResult<[Category]>

    // 카테고리 생성
    // parentID == nil → 상위 카테고리
    func createCategory(workspaceId: UUID, parentId: UUID?, name: String, color: TagColor) async -> DomainResult<Category>

    // 카테고리 수정
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void>

    // 카테고리 삭제
    func deleteCategory(id: UUID) async -> DomainResult<Void>

    // 카테고리 순서 변경
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void>
}

final class CategoryUsecase: CategoryUsecaseProtocol {
    private let repository: CategoryRepositoryProtocol
    
    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchCategories(workspaceId: UUID) async -> DomainResult<[Category]> {
        await repository.fetchCategories(workspaceId: workspaceId).toDomainResult()
    }
    
    func createCategory(workspaceId: UUID, parentId: UUID?, name: String, color: TagColor) async -> DomainResult<Category> {
        await repository.createCategory(workspaceId: workspaceId, parentId: parentId, name: name, color: color).toDomainResult()
    }
    
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void> {
        await repository.updateCategory(id: id, category: category).toDomainResult()
    }
    
    func deleteCategory(id: UUID) async -> DomainResult<Void> {
        await repository.deleteCategory(id: id).toDomainResult()
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await repository.reorderCategories(workspaceId: workspaceId, order: order).toDomainResult()
    }
}
