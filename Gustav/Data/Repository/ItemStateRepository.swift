//
//  CategoryRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.

import Foundation

final class ItemStateRepository: ItemStateRepositoryProtocol {
    
    private let dataSource: ItemStateDataSourceProtocol
    private let cache: ItemStateCache
    init(dataSource remote: ItemStateDataSourceProtocol, cache: ItemStateCache) {
        self.dataSource = remote
        self.cache = cache
    }
    
    func fetchItemStates(workspaceId: UUID) async -> DomainResult<[ItemState]> {
        let result = await self.cache.getAll(for: workspaceId)
        if !result.isEmpty {
            return .success(result)
        }
        switch await dataSource.fetchItemStates(workspaceId: workspaceId).toDomainResult() {
        case .success(let itemState):
            await self.cache.save(itemStates: itemState, for: workspaceId)
            return .success(itemState)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetchItemState(id: UUID, workspaceId: UUID) async -> DomainResult<ItemState> {
        if let cache = await self.cache.get(id: id, workspaceId: workspaceId) {
            return .success(cache)
        }
        switch await dataSource.fetchItemState(id: id).toDomainResult() {
            case .success(let itemState):
            await self.cache.insert(itemState)
            return .success(itemState)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createItemState(itemState: ItemState) async -> DomainResult<ItemState> {
        switch await dataSource.createItemState(itemState: itemState).toDomainResult() {
        case .success(let itemState):
            await self.cache.insert(itemState)
            return .success(itemState)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updateItemState(id: UUID, itemState: ItemState) async -> DomainResult<Void> {
        let reuslt = await dataSource.updateItemState(id: id, itemState: itemState).toDomainResult()
        if case .success = reuslt {
            await self.cache.update(itemState)
        }
        return reuslt
    }
    
    func deleteItemState(id: UUID, workspaceId: UUID) async -> DomainResult<Void> {
        let result = await dataSource.deleteItemState(id: id).toDomainResult()
        if case .success = result {
            await self.cache.remove(id: id, workspaceId: workspaceId)
        }
        return result
    }
    
    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        let result = await dataSource.reorderItemStates(workspaceId: workspaceId, order: order).toDomainResult()
        if case .success = result {
            await self.cache.updateOrder(workspaceId: workspaceId, order: order)
        }
        return result 
    }
    
}
