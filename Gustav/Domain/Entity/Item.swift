//
//  Item.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 정보
struct Item {
    let id: UUID                     // 아이템 고유 ID
    let workspaceId: UUID            // 소속 워크스페이스 ID
    let indexKey: Int                // 정렬 순서
    let name: String                 // 아이템 이름
    let nameDetail: String?          // 아이템 상세 이름
    let categoryId: UUID?            // 카테고리 ID
    let stateId: UUID?               // 상태 ID
    let locationId: UUID?            // 위치 ID
    let purchaseDate: String?        // 구매 날짜
    let purchasePlace: String?       // 구매처
    let warrantyExpireAt: String?    // 보증 만료일
    let price: Int?                  // 가격
    let quantity: Int?               // 수량
    let memo: String?                // 메모
    let createdAt: Date?             // 생성 시각
    let updatedAt: Date?             // 수정 시각
}
