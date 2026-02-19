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
    
    func fetchViewPresets(workspaceId: UUID) async -> RepositoryResult<[ViewPreset]> {
        do {
            let result = try await dataSource.fetchViewPresets(workspaceId: workspaceId).get()
            guard !result.isEmpty else {
                return .success([])
            }
            return .success(result.map { $0.toEntity() })
        } catch {
            return .failure(.decoding)
        }
        
    }
    
    func createViewPreset(workspaceId: UUID, preset: ViewPreset) async -> RepositoryResult<ViewPreset> {
        do {
            let result = try await dataSource.createViewPreset(workspaceId: workspaceId, dto: preset.toDTO()).get()
            return .success(result.toEntity())
        } catch {
            return .failure(.decoding)
        }
    }
    
    func updateViewPreset(id: UUID, preset: ViewPreset) async -> RepositoryResult<Void> {
        let result = await dataSource.updateViewPreset(id: id, dto: preset.toDTO())
        return .success(())
    }
    
    func deleteViewPreset(id: UUID) async -> RepositoryResult<Void> {
        let result = await dataSource.deleteViewPreset(id: id)
        return .success(())
    }
}
