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
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case indexKey = "index_key"
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
