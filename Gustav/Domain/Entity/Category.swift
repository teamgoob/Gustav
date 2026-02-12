//
//  Category.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 카테고리 정보
struct Category {
    let id: UUID               // 카테고리 고유 ID
    let workspaceId: UUID      // 워크스페이스 ID
    let parentId: UUID?        // 부모 카테고리 ID
    let indexKey: Int          // 정렬 순서
    let name: String           // 카테고리 이름
    let color: TagColor  // 카테고리 색상
}
