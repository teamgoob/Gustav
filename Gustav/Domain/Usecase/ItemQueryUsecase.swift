//
//  ItemQueryUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 조건 기반 워크스페이스 아이템 조회 Usecase
protocol ItemQueryUsecaseProtocol {
    // 조건 기반 워크스페이스 아이템 조회 - 정렬 / 필터 / 검색 포함
    func queryItems(workspaceId: UUID, query: ItemQuery) async -> DomainResult<[Item]>
}

final class ItemQueryUsecase: ItemQueryUsecaseProtocol {
    let itemRepository: ItemRepositoryProtocol      // Repo
    
    init(itemRepository: ItemRepositoryProtocol) {
        self.itemRepository = itemRepository
    }
    
    func queryItems(workspaceId: UUID, query: ItemQuery) async -> DomainResult<[Item]> {
        await itemRepository.queryItems(workspaceId: workspaceId, query: query).toDomainResult()
    }
}
