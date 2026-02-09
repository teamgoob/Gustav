//
//  WorkspaceContextUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - WorkspaceContext를 불러오는 Usecase
protocol WorkspaceContextUsecaseProtocol {
    // 워크스페이스 정보 조회 - Category / State / Location 포함
    func fetchContext(workspaceId: UUID) async -> DomainResult<WorkspaceContext>
}

final class WorkspaceContextUsecase: WorkspaceContextUsecaseProtocol {
    func fetchContext(workspaceId: UUID) async -> DomainResult<WorkspaceContext> {
        <#code#>
    }
}
