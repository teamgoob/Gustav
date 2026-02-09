//
//  ViewPresetRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 보기 프리셋 Repository Protocol
protocol ViewPresetRepositoryProtocol {
    // 프리셋 목록 조회 (created_at 기준)
    func fetchViewPresets(workspaceId: UUID) -> RepositoryResult<[ViewPreset]>

    // 프리셋 생성
    func createViewPreset(workspaceId: UUID, preset: ViewPreset) -> RepositoryResult<ViewPreset>

    // 프리셋 수정
    func updateViewPreset(id: UUID, preset: ViewPreset) -> RepositoryResult<Void>

    // 프리셋 삭제
    func deleteViewPreset(id: UUID) -> RepositoryResult<Void>
}
