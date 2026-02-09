//
//  ItemRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 Repository Protocol
protocol ItemRepositoryProtocol {
    // 워크스페이스 내 전체 아이템 목록 조회 (기본)
    func fetchItems(workspaceId: UUID) -> RepositoryResult<[Item]>

    // 워크스페이스 내 조건 기반 아이템 조회
    func queryItems(workspaceId: UUID, query: ItemQuery) -> RepositoryResult<[Item]>

    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) -> RepositoryResult<Item>

    // 아이템 수정
    func updateItem(id: UUID, item: Item) -> RepositoryResult<Void>

    // 아이템 삭제
    func deleteItem(id: UUID) -> RepositoryResult<Void>

    // 아이템 순서 변경 (indexKey)
    func reorderItems(workspaceId: UUID, order: [UUID]) -> RepositoryResult<Void>
}
