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
    func reorderCategories(order: [UUID]) async -> DomainResult<Void>
}

final class CategoryUsecase: CategoryUsecaseProtocol {
    func fetchCategories(workspaceId: UUID) async -> DomainResult<[Category]> {
        <#code#>
    }
    
    func createCategory(workspaceId: UUID, parentId: UUID?, name: String, color: TagColor) async -> DomainResult<Category> {
        <#code#>
    }
    
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void> {
        <#code#>
    }
    
    func deleteCategory(id: UUID) async -> DomainResult<Void> {
        <#code#>
    }
    
    func reorderCategories(order: [UUID]) async -> DomainResult<Void> {
        <#code#>
    }
}
