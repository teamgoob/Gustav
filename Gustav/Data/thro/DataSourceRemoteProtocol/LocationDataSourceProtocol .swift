//
//  LocationRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 장소 DataSourceProtocol

protocol LocationDataSourceProtocol {
    
    func fetchLocations(workspaceId: UUID) async -> RepositoryResult<[LocationDTO]>

    func fetchLocation(id: UUID) async -> RepositoryResult<LocationDTO?>
    
    func createLocation(location: Location) async -> RepositoryResult<LocationDTO>

    func updateLocation(id: UUID, location: Location) async -> RepositoryResult<Void>

    func deleteLocation(id: UUID) async -> RepositoryResult<Void>

    func reorderLocations(
        workspaceId: UUID,
        order: [UUID]
    ) async -> RepositoryResult<Void>
}
