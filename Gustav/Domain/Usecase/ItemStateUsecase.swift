//
//  ItemStateUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 아이템 상태 관리 Usecase
protocol ItemStateUsecaseProtocol {
    // 워크스페이스 내 아이템 상태 목록 조회
    func fetchItemStates(workspaceId: UUID) async -> DomainResult<[ItemState]>

    // 아이템 상태 생성
    func createItemState(workspaceId: UUID, name: String, color: TagColor) async -> DomainResult<ItemState>

    // 아이템 상태 수정
    func updateItemState(id: UUID, itemState: ItemState) async -> DomainResult<Void>

    // 아이템 상태 삭제
    func deleteItemState(id: UUID) async -> DomainResult<Void>

    // 아이템 상태 순서 변경
    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void>
}

final class ItemStateUsecase: ItemStateUsecaseProtocol {
    private let repository: ItemStateRepositoryProtocol
    
    init(repository: ItemStateRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchItemStates(workspaceId: UUID) async -> DomainResult<[ItemState]> {
        await repository.fetchItemStates(workspaceId: workspaceId).toDomainResult()
    }
    
    func createItemState(workspaceId: UUID, name: String, color: TagColor) async -> DomainResult<ItemState> {
        await repository.createItemState(workspaceId: workspaceId, name: name, color: color).toDomainResult()
    }
    
    func updateItemState(id: UUID, itemState: ItemState) async -> DomainResult<Void> {
        await repository.updateItemState(id: id, itemState: itemState).toDomainResult()
    }
    
    func deleteItemState(id: UUID) async -> DomainResult<Void> {
        await repository.deleteItemState(id: id).toDomainResult()
    }
    
    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await repository.reorderItemStates(workspaceId: workspaceId, order: order).toDomainResult()
    }
}
