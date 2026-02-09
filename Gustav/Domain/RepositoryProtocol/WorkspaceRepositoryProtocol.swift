//
//  WorkspaceRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 Repository Protocol
protocol WorkspaceRepositoryProtocol {
    // 워크스페이스 목록 조회
    func fetchWorkspaces(userId: UUID) -> RepositoryResult<[Workspace]>

    // 워크스페이스 생성
    func createWorkspace(userId: UUID, name: String) -> RepositoryResult<Workspace>

    // 워크스페이스 삭제
    func deleteWorkspace(id: UUID) -> RepositoryResult<Void>

    // 워크스페이스 수정
    func updateWorkspaceName(id: UUID, name: String) -> RepositoryResult<Void>

    // 워크스페이스 순서 변경 (indexKey)
    func reorderWorkspaces(userId: UUID, order: [UUID]) -> RepositoryResult<Void>
}
