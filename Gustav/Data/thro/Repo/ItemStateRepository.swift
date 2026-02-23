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
    
    func fetchItemStates(workspaceId: UUID) async -> DomainResult<[ItemState]> {
        await dataSource.fetchItemStates(workspaceId: workspaceId).toDomainResult()
    }
    
    func fetchItemState(id: UUID) async -> DomainResult<ItemState> {
        await dataSource.fetchItemState(id: id).toDomainResult()
    }
    
    func createItemState(itemState: ItemState) async -> DomainResult<ItemState> {
        await dataSource.createItemState(itemState: itemState).toDomainResult()
    }
    
    func updateItemState(id: UUID, itemState: ItemState) async -> DomainResult<Void> {
        await dataSource.updateItemState(id: id, itemState: itemState).toDomainResult()
    }
    
    func deleteItemState(id: UUID) async -> DomainResult<Void> {
        await dataSource.deleteItemState(id: id).toDomainResult()
    }
    
    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await dataSource.reorderItemStates(workspaceId: workspaceId, order: order).toDomainResult()
    }
    
}
