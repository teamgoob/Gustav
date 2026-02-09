//
//  FilterOption.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 필터 옵션
enum FilterOption {
    case category(UUID)
    case itemState(UUID)
    case location(UUID)
}
