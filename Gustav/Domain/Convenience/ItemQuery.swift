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
    let sortOption: SortingOption?
    // 필터 옵션들
    let filters: [FilterOption]
    // 검색 텍스트
    let searchText: String?
    // 페이지네이션 정보
    let pagination: Pagination?
}
