//
//  LocationUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 장소 관리 Usecase
protocol LocationUsecaseProtocol {
    // 워크스페이스 내 장소 목록 조회
    func fetchLocations(workspaceId: UUID) async -> DomainResult<[Location]>

    // 장소 생성
    func createLocation(workspaceId: UUID, name: String, color: TagColor) async -> DomainResult<Location>

    // 장소 수정
    func updateLocation(id: UUID, location: Location) async -> DomainResult<Void>

    // 장소 삭제
    func deleteLocation(id: UUID) async -> DomainResult<Void>

    // 장소 순서 변경
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void>
}

final class LocationUsecase: LocationUsecaseProtocol {
    private let repository: LocationRepositoryProtocol
    
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchLocations(workspaceId: UUID) async -> DomainResult<[Location]> {
        await repository.fetchLocations(workspaceId: workspaceId).toDomainResult()
    }
    
    func createLocation(workspaceId: UUID, name: String, color: TagColor) async -> DomainResult<Location> {
        await repository.createLocation(workspaceId: workspaceId, name: name, color: color).toDomainResult()
    }
    
    func updateLocation(id: UUID, location: Location) async -> DomainResult<Void> {
        await repository.updateLocation(id: id, location: location).toDomainResult()
    }
    
    func deleteLocation(id: UUID) async -> DomainResult<Void> {
        await repository.deleteLocation(id: id).toDomainResult()
    }
    
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
        await repository.reorderLocations(workspaceId: workspaceId, order: order).toDomainResult()
    }
}
