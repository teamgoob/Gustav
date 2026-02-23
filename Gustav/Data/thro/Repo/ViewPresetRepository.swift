//
//  ViewPresetRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.

import Foundation

final class ViewPresetRepository: ViewPresetRepositoryProtocol {
    
    private let dataSource: ViewPresetDataSourceProtocol 
    
    init(dataSource remote: ViewPresetDataSourceProtocol) {
        self.dataSource = remote
    }
    
    func fetchViewPresets(workspaceId: UUID) async -> DomainResult<[ViewPreset]> {
        await dataSource.fetchViewPresets(workspaceId: workspaceId).toDomainResult()
    }
    
    func createViewPreset(workspaceId: UUID, preset: ViewPreset) async -> DomainResult<ViewPreset> {
        await dataSource.createViewPreset(workspaceId: workspaceId, viewPreset: preset).toDomainResult()
    }
    
    func updateViewPreset(id: UUID, preset: ViewPreset) async -> DomainResult<Void> {
        await dataSource.updateViewPreset(id: id, viewPreset: preset).toDomainResult()
    }
    
    func deleteViewPreset(id: UUID) async -> DomainResult<Void> {
        await dataSource.deleteViewPreset(id: id).toDomainResult()
    }
}
