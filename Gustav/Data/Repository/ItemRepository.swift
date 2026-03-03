//
//  ItemRepository.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/20.
//

import Foundation

// MARK: - ItemRepository
// ItemRepository 구현체
final class ItemRepository: ItemRepositoryProtocol {
    // Supabase API 호출을 담당하는 remote datasource
    private let remote: ItemDataSourceProtocol
    init(remote: ItemDataSourceProtocol) {
        self.remote = remote
    }
    
    // 워크스페이스 내 전체 아이템 목록 조회 (기본)
    func fetchItems(workspaceId: UUID, pagination: Pagination?) async -> DomainResult<[Item]> {
        await remote.fetchItems(workspaceId: workspaceId, pagination: pagination).toDomainResult()
    }
    
    // 워크스페이스 내 조건 기반 아이템 조회
    func queryItems(workspaceId: UUID, query: ItemQuery, pagination: Pagination?) async -> DomainResult<[Item]> {
        await remote.queryItems(workspaceId: workspaceId, query: query, pagination: pagination).toDomainResult()
    }
    
    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item> {
        await remote.createItem(workspaceId: workspaceId, item: item).toDomainResult()
    }
    
    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void> {
        await remote.updateItem(id: id, item: item).toDomainResult()
    }
    
    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void> {
        await remote.deleteItem(id: id).toDomainResult()
    }
    
    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await remote.reorderItems(workspaceId: workspaceId, order: order).toDomainResult()
    }
}
