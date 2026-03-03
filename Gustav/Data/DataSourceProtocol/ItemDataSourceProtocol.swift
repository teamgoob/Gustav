//
//  ItemDataSourceProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/20.
//

import Foundation

// MARK: - ItemDataSourceProtocol
// 아이템 원격 데이터 소스 프로토콜
protocol ItemDataSourceProtocol {
    // 워크스페이스 내 전체 아이템 목록 조회 (기본)
    func fetchItems(workspaceId: UUID, pagination: Pagination?) async -> RepositoryResult<[ItemDTO]>

    // 워크스페이스 내 조건 기반 아이템 조회
    func queryItems(workspaceId: UUID, query: ItemQuery, pagination: Pagination?) async -> RepositoryResult<[ItemDTO]>

    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> RepositoryResult<ItemDTO>

    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> RepositoryResult<Void>

    // 아이템 삭제
    func deleteItem(id: UUID) async -> RepositoryResult<Void>

    // 아이템 순서 변경 (indexKey)
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void>
}
