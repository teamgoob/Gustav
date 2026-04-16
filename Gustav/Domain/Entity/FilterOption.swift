//
//  FilterOption.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 필터 옵션
enum FilterOption: Codable {
    case category(UUID)
    case itemState(UUID)
    case location(UUID)
    
    // 해당 필터 옵션의 UUID를 반환하는 메서드
    var uuid: UUID {
        switch self {
        case .category(let id): return id
        case .itemState(let id): return id
        case .location(let id): return id
        }
    }
}
