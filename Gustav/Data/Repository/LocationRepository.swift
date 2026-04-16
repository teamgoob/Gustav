//
//  LocationRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.

import Foundation

final class LocationRepository: LocationRepositoryProtocol {
    private let dataSource: LocationDataSourceProtocol
    private let cache: LocationCache
    init(dataSource remote: LocationDataSourceProtocol, cache: LocationCache) {
        self.dataSource = remote
        self.cache = cache
    }
    
    func fetchLocations(workspaceId: UUID) async -> DomainResult<[Location]> {
        let result = await self.cache.getAll(for: workspaceId)
        if !result.isEmpty {
            return .success(result)
        }
        switch await dataSource.fetchLocations(workspaceId: workspaceId).toDomainResult() {
        case .success(let locations):
            await self.cache.save(locations: locations, for: workspaceId)
            return .success(locations)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetchLocation(id: UUID, workspaceId: UUID) async -> DomainResult<Location> {
        if let result = await self.cache.get(id: id, workspaceId: workspaceId) {
            return .success(result)
        }
        switch await dataSource.fetchLocation(id: id).toDomainResult() {
        case .success(let location):
            await self.cache.insert(location)
            return .success(location)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createLocation(workspaceId: UUID, location: Location) async -> DomainResult<Location> {
        switch await dataSource.createLocation(location: location).toDomainResult() {
        case .success:
            await self.cache.insert(location)
            return .success(location)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updateLocation(id: UUID, location: Location) async -> DomainResult<Void> {
        let result = await dataSource.updateLocation(id: id, location: location).toDomainResult()
        if case .success = result {
            await self.cache.update(location)
        }
        return result
    }
    
    func deleteLocation(id: UUID, workspaceId: UUID) async -> DomainResult<Void> {
        let result = await dataSource.deleteLocation(id: id).toDomainResult()
        if case .success = result {
            await self.cache.remove(id: id, workspaceId: workspaceId)
        }
        return result
    }
    
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        let reuslt = await dataSource.reorderLocations(workspaceId: workspaceId, order: order).toDomainResult()
        if case .success = reuslt {
            await self.cache.updateOrder(workspaceId: workspaceId, order: order)
        }
        return reuslt
    }
    
    
}
