//
//  SortingOption.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 정렬 옵션
enum SortingOption {
    case indexKey(order: SortingOrder)
    case name(order: SortingOrder)
    case nameDetail(order: SortingOrder)
    case purchaseDate(order: SortingOrder)
    case purchasePlace(order: SortingOrder)
    case expireDate(order: SortingOrder)
    case price(order: SortingOrder)
    case quantity(order: SortingOrder)
    case createdAt(order: SortingOrder)
    case updatedAt(order: SortingOrder)
}
