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

    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item>

    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void>

    // 아이템 삭제
    func deleteItem(id: UUID) async -> DomainResult<Void>

    // 아이템 순서 변경
    func reorderItems(order: [UUID]) async -> DomainResult<Void>
}

final class ItemUsecase: ItemUsecaseProtocol {
    func fetchItems(workspaceId: UUID) async -> DomainResult<[Item]> {
        <#code#>
    }
    
    func createItem(workspaceId: UUID, item: Item) async -> DomainResult<Item> {
        <#code#>
    }
    
    func updateItem(id: UUID, item: Item) async -> DomainResult<Void> {
        <#code#>
    }
    
    func deleteItem(id: UUID) async -> DomainResult<Void> {
        <#code#>
    }
    
    func reorderItems(order: [UUID]) async -> DomainResult<Void> {
        <#code#>
    }
}
