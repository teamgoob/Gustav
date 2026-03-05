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
    func fetchItems(workspaceId: UUID, pagination: Pagination?) async -> DomainResult<[Item]>

    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item>

    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void>

    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void>

    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void>
}

final class ItemUsecase: ItemUsecaseProtocol {
    
    let repository: ItemRepositoryProtocol  // Repo
    
    // 생성자
    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
    }
    
    // index Key를 기준 전체 조회
    func fetchItems(workspaceId: UUID, pagination: Pagination?) async -> DomainResult<[Item]> {
        await repository.fetchItems(workspaceId: workspaceId, pagination: pagination)
    }
    
    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item> {
        await repository.createItem(workspaceId: workspaceId, item: item)
    }
    
    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void> {
        await repository.updateItem(id: id, item: item)
    }
    
    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void> {
        await repository.deleteItem(id: id)
    }
    
    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await repository.reorderItems(workspaceId: workspaceId, order: order)
    }
}
