//
//  WorkspaceRepository.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - WorkspaceRepository
// WorkspaceRepository 구현체
final class WorkspaceRepository: WorkspaceRepositoryProtocol {
    // Supabase API 호출을 담당하는 remote datasource
    // 로컬 캐싱을 담당하는 cache datasource
    private let remote: WorkspaceDataSourceProtocol
    private let cache: WorkspaceCache
    
    init(remote: WorkspaceDataSourceProtocol, cache: WorkspaceCache) {
        self.remote = remote
        self.cache = cache
    }
    
    // 워크스페이스 목록 조회
    func fetchWorkspaces(userId: UUID) async -> DomainResult<[Workspace]> {
        // 캐시 확인
        let cached = await cache.getAll()
        if !cached.isEmpty {
            return .success(cached)
        }
        
        // 원격 데이터 호출
        let result = await remote.fetchWorkspaces(userId: userId)
        let domainResult = result.toDomainResult()
        
        // 성공 시 캐시에 저장
        if case .success(let entities) = domainResult {
            await cache.save(entities)
        }
        
        return domainResult
    }
    
    // 단일 워크스페이스 조회
    func fetchWorkspace(id: UUID) async -> DomainResult<Workspace> {
        // 캐시 확인
        if let cached = await cache.get(id: id) {
            return .success(cached)
        }
        
        // 원격 데이터 호출
        let result = await remote.fetchWorkspace(id: id)
        let domainResult = result.toDomainResult()
        
        // 성공 시 캐시에 추가
        if case .success(let entity) = domainResult {
            await cache.insert(entity)
        }
        
        return domainResult
    }
    
    // 워크스페이스 생성
    func createWorkspace(userId: UUID, name: String) async -> DomainResult<Workspace> {
        // 원격 데이터 생성
        let result = await remote.createWorkspace(userId: userId, name: name)
        
        let domainResult = result.toDomainResult()
        
        // 성공 시 캐시에 추가
        if case .success(let entity) = domainResult {
            await cache.insert(entity)
        }
        
        return domainResult
    }
    
    // 워크스페이스 이름 변경
    func updateWorkspaceName(id: UUID, name: String) async -> DomainResult<Void> {
        // 원격 데이터 수정
        let result = await remote.updateWorkspaceName(id: id, name: name)
        
        let domainResult = result.toDomainResult()
        
        // 성공 시 캐시 수정
        if case .success = domainResult {
            await cache.updateName(id: id, name: name)
        }
        
        return domainResult
    }
    
    // 워크스페이스 삭제
    func deleteWorkspace(id: UUID) async -> DomainResult<Void> {
        // 원격 데이터 삭제
        let result = await remote.deleteWorkspace(id: id)
        let domainResult = result.toDomainResult()
        
        // 성공 시 캐시 삭제
        if case .success = domainResult {
            await cache.remove(id: id)
        }
        
        return domainResult
    }
    
    // 워크스페이스 순서 변경
    func reorderWorkspaces(userId: UUID, order: [UUID]) async -> DomainResult<Void> {
        // 원격 데이터 수정
        let result = await remote.reorderWorkspaces(userId: userId, order: order)
        let domainResult = result.toDomainResult()
        
        // 성공 시 캐시 수정
        if case .success = domainResult {
            await cache.updateOrder(order: order)
        }
        
        return domainResult
    }
}
