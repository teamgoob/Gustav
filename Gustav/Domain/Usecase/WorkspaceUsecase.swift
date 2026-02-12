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
    
    //userID 들고오려고
    private let authRepository: AuthRepositoryProtocol
    private let workspaceRepository: WorkspaceRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol, workspaceRepository: WorkspaceRepositoryProtocol) {
        self.authRepository = authRepository
        self.workspaceRepository = workspaceRepository
    }
    
    // 사용자 소유 워크스페이스 목록 조회 (indexKey 기준 정렬)
    func fetchWorkspaces() async -> DomainResult<[Workspace]> {

        // 1) 현재 유저 id 확보
        let userIdResult = await authRepository.currentUserId().toDomainResult()
        switch userIdResult {
        case .failure(let error):
            return .failure(error)
        case .success(let userId):

            // 2) Repository 호출
            let repoResult = await workspaceRepository.fetchWorkspaces(userId: userId)

            // 3) RepoResult -> DomainResult 변환 + 도메인 규칙(정렬) 적용
            return repoResult
                .toDomainResult()
                .map { workspaces in
                    workspaces.sorted { $0.indexKey < $1.indexKey }
                }
        }
    }
    
    // 워크스페이스 생성
    func createWorkspace(name: String) async -> DomainResult<Workspace> {
        // 1) 현재 유저 id 확보
        let userIdResult = await authRepository.currentUserId().toDomainResult()
        switch userIdResult {
        case .failure(let error):
            return .failure(error)
        case .success(let userId):
            // 2) Repository 호출
            let repoResult = await workspaceRepository.createWorkspace(userId: userId, name: name)
            // 3) RepoResult -> DomainResult 변환
            return repoResult.toDomainResult()
        }
    }
    
    // 워크스페이스 삭제
    func deleteWorkspace(id: UUID) async -> DomainResult<Void> {
        let repoResult = await workspaceRepository.deleteWorkspace(id: id)
        return repoResult.toDomainResult()
    }
    
    // 워크스페이스 이름 변경
    func updateWorkspaceName(id: UUID, name: String) async -> DomainResult<Void> {
        let repoResult = await workspaceRepository.updateWorkspaceName(id: id, name: name)
        return repoResult.toDomainResult()
    }
    
    // 워크스페이스 순서 변경
    // indexKey 재정렬
    func reorderWorkspaces(order: [UUID]) async -> DomainResult<Void> {
        // 1) 현재 유저 ID 확보 (RepositoryResult -> DomainResult 변환)
        let userIdResult: DomainResult<UUID> = await authRepository
            .currentUserId()
            .toDomainResult()

        switch userIdResult {
        case .failure(let error):
            return .failure(error)

        case .success(let userId):
            // 2) Repository 호출 + Domain 변환
            let repoResult = await workspaceRepository.reorderWorkspaces(userId: userId, order: order)
            return repoResult.toDomainResult()
        }
    }
}

