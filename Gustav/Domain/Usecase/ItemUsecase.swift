//
//  ItemUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 아이템 관리 Usecase
protocol ItemUsecaseProtocol {
    // 워크스페이스 내 아이템 목록 조회
    // indexKey 기준
    func fetchItems(workspaceId: UUID) async -> DomainResult<[Item]>
    
    // 워크스페이스 내 조건 기반 아이템 조회(Query)
    func queryItems(workspaceId: UUID, query: ItemQuery) async -> RepositoryResult<[Item]>

    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item>

    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void>

    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void>

    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void>
}

struct ItemUsecase: ItemUsecaseProtocol {
    
    let repository: ItemRepositoryProtocol  // Repo
    
    // 생성자
    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
    }
    
    // index Key를 기준 전체 조회
    func fetchItems(workspaceId: UUID) async -> DomainResult<[Item]> {
        await repository.fetchItems(workspaceId: workspaceId).toDomainResult()
    }
    
    // 워크스페이스 내 조건 기반 아이템 조회(Query)
    func queryItems(workspaceId: UUID, query: ItemQuery) async -> RepositoryResult<[Item]> {
        await repository.queryItems(workspaceId: workspaceId, query: query)
    }
    
    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item> {
        await repository.createItem(workspaceId: workspaceId, item: item).toDomainResult()
    }
    
    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void> {
        await repository.updateItem(id: id, item: item).toDomainResult()
    }
    
    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void> {
        await repository.deleteItem(id: id).toDomainResult()
    }
    
    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await repository.reorderItems(workspaceId: workspaceId, order: order).toDomainResult()
    }
}
