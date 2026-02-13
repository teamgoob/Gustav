//
//  LocationRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 장소 DataSourceProtocol

protocol LocationDataSourceProtocol {
    
    func fetchLocations(workspaceId: UUID) async throws -> [LocationDTO]

    func fetchLocation(id: UUID) async throws -> LocationDTO?
    
    func createLocation(
        workspaceId: UUID,
        name: String,
        color: TagColor
    ) async throws -> LocationDTO

    func updateLocation(id: UUID, dto: LocationDTO) async throws

    func deleteLocation(id: UUID) async throws

    func reorderLocations(
        workspaceId: UUID,
        order: [UUID]
    ) async throws
}
