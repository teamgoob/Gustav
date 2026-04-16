//
//  ItemQuery.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 조회 조건
struct ItemQuery {
    // 정렬 옵션
    var sortOption: SortingOption?
    // 필터 옵션들
    var filters: [FilterOption]
    // 검색 텍스트
    var searchText: String?
}
