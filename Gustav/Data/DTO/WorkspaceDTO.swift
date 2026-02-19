//
//  WorkspaceDTO.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - WorkspaceDTO
struct WorkspaceDTO: Codable {
    let id: UUID
    let userId: UUID
    let indexKey: Int
    let name: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case indexKey = "index_key"
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Extensions: WorkspaceDTO -> Workspace 변환
extension WorkspaceDTO: DomainConvertible {
    typealias DomainType = Workspace
    
    func toDomain() -> Workspace {
        Workspace(
            id: id,
            userId: userId,
            indexKey: indexKey,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
