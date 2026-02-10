//
//  Workspace.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 워크스페이스 정보
struct Workspace {
    let id: UUID            // 워크스페이스 ID
    let userId: UUID        // 사용자 ID
    let indexKey: Decimal    // 정렬 기준 값
    let name: String        // 워크스페이스 이름
    let createdAt: Date     // 생성일
    let updatedAt: Date     // 수정일
}
