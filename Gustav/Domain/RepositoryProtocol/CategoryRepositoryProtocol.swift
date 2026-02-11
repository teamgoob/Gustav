//
//  CategoryRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 카테고리 Repository Protocol
protocol CategoryRepositoryProtocol {
    // 워크스페이스 내 전체 카테고리 조회
    func fetchCategories(workspaceId: UUID) async -> RepositoryResult<[Category]>
    
    // 워크스페이스 내 단일 카테고리 조회
    func fetchCategory(id: UUID) async -> RepositoryResult<Category>

    // 카테고리 생성
    func createCategory(workspaceId: UUID, parentId: UUID?, name: String, color: TagColor) async -> RepositoryResult<Category>

    // 카테고리 수정
    func updateCategory(id: UUID, category: Category) async -> RepositoryResult<Void>

    // 카테고리 삭제
    func deleteCategory(id: UUID) async -> RepositoryResult<Void>

    // 카테고리 순서 변경 (index_key)
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void>
}
