//
//  ViewPresetUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 보기 프리셋 관리 Usecase
protocol ViewPresetUsecaseProtocol {
    // 워크스페이스 내 프리셋 목록 조회
    // created_at 기준 정렬
    func fetchViewPresets(workspaceId: UUID) async -> DomainResult<[ViewPreset]>

    // 프리셋 생성
    func createViewPreset(workspaceId: UUID, preset: ViewPreset) async -> DomainResult<ViewPreset>

    // 프리셋 수정
    func updateViewPreset(id: UUID, preset: ViewPreset) async -> DomainResult<Void>

    // 프리셋 삭제
    func deleteViewPreset(id: UUID) async -> DomainResult<Void>
}

final class ViewPresetUsecase: ViewPresetUsecaseProtocol {
    private let repository: ViewPresetRepositoryProtocol
    
    init(repository: ViewPresetRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchViewPresets(workspaceId: UUID) async -> DomainResult<[ViewPreset]> {
        await repository.fetchViewPresets(workspaceId: workspaceId).toDomainResult()
    }
    
    func createViewPreset(workspaceId: UUID, preset: ViewPreset) async -> DomainResult<ViewPreset> {
        await repository.createViewPreset(workspaceId: workspaceId, preset: preset).toDomainResult()
    }
    
    func updateViewPreset(id: UUID, preset: ViewPreset) async -> DomainResult<Void> {
        await repository.updateViewPreset(id: id, preset: preset).toDomainResult()
    }
    
    func deleteViewPreset(id: UUID) async -> DomainResult<Void> {
        await repository.deleteViewPreset(id: id).toDomainResult()
    }
}
