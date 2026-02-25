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
    private let cache: ItemCache
    init(remote: ItemDataSourceProtocol, cache: ItemCache) {
        self.remote = remote
        self.cache = cache
    }
    
    // 워크스페이스 내 전체 아이템 목록 조회 (기본)
    func fetchItems(workspaceId: UUID, pagination: Pagination?) async -> DomainResult<[Item]> {
        let cached = await cache.getAll()
        if !cached.isEmpty {
            return .success(cached)
        }
        let result = await remote.fetchItems(workspaceId: workspaceId, pagination: pagination).toDomainResult()
        
        // 성공시 캐시 저장
        if case .success(let items) = result {
            await cache.save(items)
        }
        return result
    }
    
    // 워크스페이스 내 조건 기반 아이템 조회
    func queryItems(workspaceId: UUID, query: ItemQuery, pagination: Pagination?) async -> DomainResult<[Item]> {
        await remote.queryItems(workspaceId: workspaceId, query: query, pagination: pagination).toDomainResult()
        // Cache에 관련 메서드 구현 후 추가 필요
    }
    
    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item> {
        let result = await remote.createItem(workspaceId: workspaceId, item: item).toDomainResult()
        if case .success(let newItem) = result {
            await cache.insert(newItem)
        }
        return result
    }
    
    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void> {
        let result = await remote.updateItem(id: id, item: item).toDomainResult()
        if case .success = result {
            await cache.updateItem(item: item)
        }
        return result
    }
    
    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void> {
        switch await remote.deleteItem(id: id).toDomainResult() {
        case .success:
            await cache.remove(id: id)
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        switch await remote.reorderItems(workspaceId: workspaceId, order: order).toDomainResult() {
        case .success:
            await cache.updateOrder(order: order)
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
