//
//  ViewPreset.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 보기 프리셋 정보
struct ViewPreset {
    let id: UUID              // 프리셋 ID
    let workspaceId: UUID     // 소속 워크스페이스 ID
    let name: String          // 프리셋 이름
    let viewType: Int         // 뷰 타입
    let sortingOption: Int    // 정렬 기준
    let sortingOrder: Int     // 정렬 순서
    let categoryId: UUID?     // 카테고리 필터
    let stateId: UUID?        // 상태 필터
    let locationId: UUID?     // 위치 필터
    let createdAt: String?    // 생성 시각
    let updatedAt: String?    // 수정 시각
}
