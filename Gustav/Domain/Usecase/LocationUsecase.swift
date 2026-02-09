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
    func reorderLocations(order: [UUID]) async -> DomainResult<Void>
}

final class LocationUsecase: LocationUsecaseProtocol {
    func fetchLocations(workspaceId: UUID) async -> DomainResult<[Location]> {
        <#code#>
    }
    
    func createLocation(workspaceId: UUID, name: String, color: TagColor) async -> DomainResult<Location> {
        <#code#>
    }
    
    func updateLocation(id: UUID, location: Location) async -> DomainResult<Void> {
        <#code#>
    }
    
    func deleteLocation(id: UUID) async -> DomainResult<Void> {
        <#code#>
    }
    
    func reorderLocations(order: [UUID]) async -> DomainResult<Void> {
        <#code#>
    }
}
