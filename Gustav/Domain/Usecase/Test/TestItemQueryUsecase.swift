//
//  TestItemQueryUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/4/1.
//

import Foundation

// MARK: - TestItemQueryUsecase
// UI 테스트용 ItemQueryUsecase
final class TestItemQueryUsecase: ItemQueryUsecaseProtocol {
    func queryItems(workspaceId: UUID, query: ItemQuery, pagination: Pagination?) async -> DomainResult<[Item]> {
        return .success([])
    }
}
