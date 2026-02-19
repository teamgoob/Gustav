//
//  LocationRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 장소 Repository Protocol
protocol LocationRepositoryProtocol {
    // 워크스페이스 내 전체 장소 조회
    func fetchLocations(workspaceId: UUID) async -> DomainResult<[Location]>

    // 워크스페이스 내 단일 장소 조회
    func fetchLocation(id: UUID) async -> DomainResult<Location>
    
    // 장소 생성
    func createLocation(workspaceId: UUID, name: String, color: TagColor) async -> DomainResult<Location>

    // 장소 수정
    func updateLocation(id: UUID, location: Location) async -> DomainResult<Void>

    // 장소 삭제
    func deleteLocation(id: UUID) async -> DomainResult<Void>

    // 장소 순서 변경
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void>
}
