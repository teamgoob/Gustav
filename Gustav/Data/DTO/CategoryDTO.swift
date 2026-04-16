//
//  Category.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 카테고리 정보
struct CategoryDTO: Codable {
    let id: UUID              // 카테고리 ID
    let workspaceId: UUID     // 소속 워크스페이스 ID
    let parentId: UUID?       // 상위 카테고리 ID(nil인 경우 상위, 존재하는 경우 하위)
    let indexKey: Int         // 정렬 순서
    let name: String          // 카테고리 이름
    let color: Int?           // 카테고리 색상
    let createdAt: Date?     // 생성 시각
    let updatedAt: Date?    // 수정 시각
    
    enum CodingKeys: String, CodingKey {
        case id
        case workspaceId = "workspace_id"
        case parentId = "parent_id"
        case indexKey = "index_key"
        case name
        case color
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Encodable 커스텀 인코딩
    // parentId를 nil로 입력할 때 JSON에서 필드가 제거되는 기본 동작을 방지하고,
    // 명시적으로 "null"을 전달하기 위해 커스텀 인코딩을 구현
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(workspaceId, forKey: .workspaceId)

        if let parentId {
            try container.encode(parentId, forKey: .parentId)
        } else {
            try container.encodeNil(forKey: .parentId)
        }

        try container.encode(indexKey, forKey: .indexKey)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}
