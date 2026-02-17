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
    let indexKey: Decimal?    // 정렬 순서
    let name: String          // 카테고리 이름
    let color: Int?           // 카테고리 색상
    let createdAt: String?    // 생성 시각
    let updatedAt: String?    // 수정 시각
    
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
}

extension CategoryDTO {
    func toEntity() -> Category {
        // nil이면 0 (기본값)
        // Decimal -> Int 변환은 NSDecimalNumber를 쓰는 게 안전함
        let indexKeyInt: Int = {
            guard let decimal = self.indexKey else { return 0 }           // nil -> 0
            return NSDecimalNumber(decimal: decimal).intValue             // Decimal -> Int
        }()
        let colorValue: Int = self.color ?? 0
        let tagColor: TagColor = TagColor(rawValue: colorValue) ?? .darkGray

        // ✅ 3) Category는 createdAt/updatedAt을 안 받음 (넘기면 Extra arguments 에러)
        return Category(
            id: self.id,
            workspaceId: self.workspaceId,
            parentId: self.parentId,
            indexKey: indexKeyInt,
            name: self.name,
            color: tagColor
        )
    }
}
