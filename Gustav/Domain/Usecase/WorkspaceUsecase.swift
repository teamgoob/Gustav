//
//  WorkspaceUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 목록 관리 Usecase
protocol WorkspaceUsecaseProtocol {
    // 사용자 소유 워크스페이스 목록 조회
    // indexKey 기준 정렬
    func fetchWorkspaces() async -> DomainResult<[Workspace]>

    // 워크스페이스 생성
    func createWorkspace(name: String) async -> DomainResult<Workspace>

    // 워크스페이스 삭제
    func deleteWorkspace(id: UUID) async -> DomainResult<Void>

    // 워크스페이스 이름 변경
    func updateWorkspaceName(id: UUID, name: String) async -> DomainResult<Void>

    // 워크스페이스 순서 변경
    // indexKey 재정렬
    func reorderWorkspaces(order: [UUID]) async -> DomainResult<Void>
}

final class WorkspaceUsecase: WorkspaceUsecaseProtocol {
    func fetchWorkspaces() async -> DomainResult<[Workspace]> {
        <#code#>
    }
    
    func createWorkspace(name: String) async -> DomainResult<Workspace> {
        <#code#>
    }
    
    func deleteWorkspace(id: UUID) async -> DomainResult<Void> {
        <#code#>
    }
    
    func updateWorkspaceName(id: UUID, name: String) async -> DomainResult<Void> {
        <#code#>
    }
    
    func reorderWorkspaces(order: [UUID]) async -> DomainResult<Void> {
        <#code#>
    }
}
