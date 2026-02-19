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
    
    func fetchLocations(workspaceId: UUID) async -> RepositoryResult<[Location]> {
        var locations: [Location] = []
        do {
            let result = try await dataSource.fetchLocations(workspaceId: workspaceId).get()
            guard !result.isEmpty else {
                return .success([])
            }
            locations = result.map { $0.toEntity() }
            return .success(locations)
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func fetchLocation(id: UUID) async -> RepositoryResult<Location> {
        do {
            let result = try await dataSource.fetchLocation(id: id).get()
            guard let result else {
                return .failure(RepositoryError.notFound)   // 임시, Repo protocol 변경 필요
            }
            return .success(result.toEntity())
        } catch {
            return .failure(RepositoryError.decoding)   //  임시
        }
    }
    
    func createLocation(workspaceId: UUID, name: String, color: TagColor) async -> RepositoryResult<Location> {
        // Repo Protocol 수정 후 추가
    }
    
    func updateLocation(id: UUID, location: Location) async -> RepositoryResult<Void> {
        _ = await dataSource.updateLocation(id: id, dto: location.toDTO())
        return .success(())
    }
    
    func deleteLocation(id: UUID) async -> RepositoryResult<Void> {
        _ = await dataSource.deleteLocation(id: id)
        return .success(())
    }
    
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        _ = await dataSource.reorderLocations(workspaceId: workspaceId, order: order)
        return .success(())
    }
    
    
}
