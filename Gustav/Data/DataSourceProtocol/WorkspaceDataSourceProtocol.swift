//
//  WorkspaceDataSourceProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - WorkspaceDataSourceProtocol
// 워크스페이스 원격 데이터 소스 프로토콜

protocol WorkspaceDataSourceProtocol {
    // 워크스페이스 목록 조회
    func fetchWorkspaces(userId: UUID) async -> RepositoryResult<[WorkspaceDTO]>
    
    // 단일 워크스페이스 조회
    func fetchWorkspace(id: UUID) async -> RepositoryResult<WorkspaceDTO>
    
    // 워크스페이스 생성
    func createWorkspace(userId: UUID, name: String) async -> RepositoryResult<WorkspaceDTO>
    
    // 워크스페이스 수정
    func updateWorkspaceName(id: UUID, name: String) async -> RepositoryResult<Void>
    
    // 워크스페이스 삭제
    func deleteWorkspace(id: UUID) async -> RepositoryResult<Void>
    
    // 워크스페이스 순서 변경 (indexKey)
    func reorderWorkspaces(userId: UUID, order: [UUID]) async -> RepositoryResult<Void>
}
