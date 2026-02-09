//
//  ItemReference.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 정보 통합 Entity
struct ItemReference {
    let item: Item           // 아이템 기본 정보
    let category: Category?  // 아이템 카테고리 정보
    let location: Location?  // 아이템 장소 정보
    let state: ItemState?    // 아이템 상태 정보
}
