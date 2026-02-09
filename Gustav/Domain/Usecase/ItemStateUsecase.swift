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
    func reorderItemStates(order: [UUID]) async -> DomainResult<Void>
}

final class ItemStateUsecase: ItemStateUsecaseProtocol {
    func fetchItemStates(workspaceID: UUID) async -> DomainResult<[ItemState]> {
        <#code#>
    }
    
    func createItemState(workspaceID: UUID, name: String, color: TagColor) async -> DomainResult<ItemState> {
        <#code#>
    }
    
    func updateItemState(id: UUID, itemState: ItemState) async -> DomainResult<Void> {
        <#code#>
    }
    
    func deleteItemState(id: UUID) async -> DomainResult<Void> {
        <#code#>
    }
    
    func reorderItemStates(order: [UUID]) async -> DomainResult<Void> {
        <#code#>
    }
}
