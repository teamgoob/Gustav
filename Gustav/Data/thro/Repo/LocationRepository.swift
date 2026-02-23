//
//  LocationRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.

import Foundation

final class LocationRepository: LocationRepositoryProtocol {
    private let dataSource: LocationDataSourceProtocol
    
    init(dataSource remote: LocationDataSourceProtocol) {
        self.dataSource = remote
    }
    
    func fetchLocations(workspaceId: UUID) async -> DomainResult<[Location]> {
        await dataSource.fetchLocations(workspaceId: workspaceId).toDomainResult()
    }
    
    func fetchLocation(id: UUID) async -> DomainResult<Location> {
        await dataSource.fetchLocation(id: id).toDomainResult()
    }
    
    func createLocation(workspaceId: UUID, location: Location) async -> DomainResult<Location> {
        await dataSource.createLocation(location: location).toDomainResult()
    }
    
    func updateLocation(id: UUID, location: Location) async -> DomainResult<Void> {
        await dataSource.updateLocation(id: id, location: location).toDomainResult()
    }
    
    func deleteLocation(id: UUID) async -> DomainResult<Void> {
        await dataSource.deleteLocation(id: id).toDomainResult()
    }
    
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await dataSource.reorderLocations(workspaceId: workspaceId, order: order).toDomainResult()
    }
    
    
}
