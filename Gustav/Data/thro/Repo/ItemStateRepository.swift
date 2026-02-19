//
//  CategoryRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.

import Foundation

final class ItemStateRepository: ItemStateRepositoryProtocol {
    
    let dataSource: ItemStateDataSourceProtocol
    
    init(dataSource remote: ItemStateDataSourceProtocol) {
        self.dataSource = remote
    }
    
    func fetchItemStates(workspaceId: UUID) async -> RepositoryResult<[ItemState]> {
        var states: [ItemState] = []
        do {
            let result = try await dataSource.fetchItemStates(workspaceId: workspaceId).get()
            guard !result.isEmpty else {
                return .success([])
            }
            states = result.map { $0.toEntity() }
            return .success(states)
        } catch {
            return .failure(RepositoryError.decoding)   //  임시
        }
    }
    
    func fetchItemState(id: UUID) async -> RepositoryResult<ItemState> {
        do {
            let result = try await dataSource.fetchItemState(id: id).get()
            guard let result else {
                return .failure(RepositoryError.notFound)   // 임시, Repo protocol 변경 필요
            }
            return .success(result.toEntity())
        } catch {
            return .failure(RepositoryError.decoding)   //  임시
        }
    }
    
    func createItemState(workspaceId: UUID, name: String, color: TagColor) async -> RepositoryResult<ItemState> {
        // Repo Protocol 수정 후 추가
    }
    
    func updateItemState(id: UUID, itemState: ItemState) async -> RepositoryResult<Void> {
            _ = await dataSource.updateItemState(id: id, dto: itemState.toDTO())
            return .success(())
    }
    
    func deleteItemState(id: UUID) async -> RepositoryResult<Void> {
        _ = await dataSource.deleteItemState(id: id)
        return .success(())
    }
    
    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        _ = await dataSource.reorderItemStates(workspaceId: workspaceId, order: order)
    }
    
}
