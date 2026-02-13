//
//  ItemRemoteDataSource.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation

// MARK: - Category DataSource
protocol CategoryDataSourceProtocol {
    
    // 워크스페이스 내 전체 카테고리 조회
    func fetchCategories(workspaceId: UUID) async throws -> [CategoryDTO]
    
    // 단일 카테고리 조회
    func fetchCategory(id: UUID) async throws -> CategoryDTO
    
    // 카테고리 생성
    func createCategory(categoryDTO: CategoryDTO) async throws -> CategoryDTO

    // 카테고리 수정
    func updateCategory(id: UUID, dto: CategoryDTO) async throws

    // 카테고리 삭제
    func deleteCategory(id: UUID) async throws

    // 카테고리 순서 변경
    func reorderCategories(workspaceId: UUID, order: [UUID] ) async throws
}
