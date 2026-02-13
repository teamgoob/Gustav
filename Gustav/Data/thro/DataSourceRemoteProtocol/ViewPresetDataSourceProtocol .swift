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
    func fetchViewPresets(workspaceId: UUID) async throws -> [ViewPresetDTO]

    func createViewPreset(
        workspaceId: UUID,
        dto: ViewPresetDTO
    ) async throws -> ViewPresetDTO

    func updateViewPreset(id: UUID, dto: ViewPresetDTO) async throws

    func deleteViewPreset(id: UUID) async throws
}
