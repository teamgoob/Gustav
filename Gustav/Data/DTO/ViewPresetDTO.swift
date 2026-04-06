//
//  ViewPreset.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 보기 프리셋 정보
struct ViewPresetDTO: Codable {
    let id: UUID                     // 프리셋 ID
    let workspaceId: UUID            // 소속 워크스페이스 ID
//    let indexKey: Int                // 정렬 순서
    let name: String                 // 프리셋 이름
    let viewType: Int                // 뷰 타입
    
    let sortingOption: Int           // 정렬 기준
    let sortingOrder: Int            // 정렬 기준
    
    let categoryId: UUID?            // 필터 옵션들
    let stateId: UUID?               // 필터 옵션들
    let locationId: UUID?            // 필터 옵션들
    
    let createdAt: Date?             // 생성 시각
    let updatedAt: Date?             // 수정 시각
    

    enum CodingKeys: String, CodingKey {
        case id
        case workspaceId = "workspace_id"
        case name
        case viewType = "view_type"
        case sortingOption = "sorting_option"
        case sortingOrder = "sorting_order"
        case categoryId = "category_id"
        case stateId = "state_id"
        case locationId = "location_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
}
