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
    func fetchLocations(workspaceId: UUID) -> RepositoryResult<[Location]>

    // 장소 생성
    func createLocation(workspaceId: UUID, name: String, color: TagColor) -> RepositoryResult<Location>

    // 장소 수정
    func updateLocation(id: UUID, location: Location) -> RepositoryResult<Void>

    // 장소 삭제
    func deleteLocation(id: UUID) -> RepositoryResult<Void>

    // 장소 순서 변경
    func reorderLocations(workspaceId: UUID, order: [UUID]) -> RepositoryResult<Void>
}
