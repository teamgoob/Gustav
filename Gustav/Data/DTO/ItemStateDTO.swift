//
//  ItemState.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 아이템 상태 정보
struct ItemStateDTO: Codable {
    let id: UUID                // 아이템 상태 고유 ID
    let workspaceId: UUID       // 워크스페이스 ID
    let indexKey: Int           // 정렬 순서
    let name: String            // 아이템 상태 이름
    let color: Int              // 아이템 상태 색상
}

extension ItemStateDTO: DomainConvertible {
    typealias DomainType = ItemState
    func toDomain() -> ItemState {
        let tagColor: TagColor = TagColor(rawValue: self.color) ?? .darkGray
        return ItemState(
            id: self.id,
            workspaceId: self.workspaceId,
            indexKey: self.indexKey,
            name: self.name,
            color: tagColor
        )
    }
}
