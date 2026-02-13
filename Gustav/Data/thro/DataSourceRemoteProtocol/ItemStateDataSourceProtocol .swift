//
//  ItemStateRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 상태 DataSourceProtocol

protocol ItemStateDataSourceProtocol {
    
    /// 워크스페이스 내 전체 아이템 상태 조회
    func fetchItemStates(workspaceId: UUID) async throws -> [ItemStateDTO]

    /// 단일 아이템 상태 조회 (없으면 nil)
    func fetchItemState(id: UUID) async throws -> ItemStateDTO?
    
    /// 아이템 상태 생성
    func createItemState(
        workspaceId: UUID,
        name: String,
        color: TagColor
    ) async throws -> ItemStateDTO

    /// 아이템 상태 수정
    func updateItemState(id: UUID, dto: ItemStateDTO) async throws

    /// 아이템 상태 삭제
    func deleteItemState(id: UUID) async throws

    /// 아이템 상태 순서 변경
    func reorderItemStates(
        workspaceId: UUID,
        order: [UUID]
    ) async throws
}
