//
//  ItemStateRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 상태 Repository Protocol
protocol ItemStateRepositoryProtocol {
    // 워크스페이스 내 전체 아이템 상태 조회
    func fetchItemStates(workspaceId: UUID) -> RepositoryResult<[ItemState]>

    // 아이템 상태 생성
    func createItemState(workspaceId: UUID, name: String, color: TagColor) -> RepositoryResult<ItemState>

    // 아이템 상태 수정
    func updateItemState(id: UUID, itemState: ItemState) -> RepositoryResult<Void>

    // 아이템 상태 삭제
    func deleteItemState(id: UUID) -> RepositoryResult<Void>

    // 아이템 상태 순서 변경
    func reorderItemStates(workspaceId: UUID, order: [UUID]) -> RepositoryResult<Void>
}
