//
//  ViewPresetRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - ViewPreset DataSourceProtocol
protocol ViewPresetDataSourceProtocol {
    // created_at 기준 정렬
    func fetchViewPresets(workspaceId: UUID) async -> RepositoryResult<[ViewPresetDTO]>

    func createViewPreset(workspaceId: UUID, viewPreset: ViewPreset) async -> RepositoryResult<ViewPresetDTO>

    func updateViewPreset(id: UUID, viewPreset: ViewPreset) async -> RepositoryResult<Void>

    func deleteViewPreset(id: UUID) async -> RepositoryResult<Void>
}
