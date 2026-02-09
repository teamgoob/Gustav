//
//  ViewPreset.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 보기 프리셋 정보
struct ViewPreset {
    let id: UUID                     // 프리셋 ID
    let workspaceId: UUID            // 소속 워크스페이스 ID
    let name: String                 // 프리셋 이름
    let viewType: Int                // 뷰 타입
    let sortingOption: SortingOption // 정렬 기준
    let filters: [FilterOption]      // 필터 옵션들
    let createdAt: Date?             // 생성 시각
    let updatedAt: Date?             // 수정 시각
}
