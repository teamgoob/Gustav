//
//  ItemProperty.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import Foundation

// MARK: - 워크스페이스 아이템 셀에서 조건에 따라 표시할 데이터를 구분하기 위한 열거형
enum ItemProperty {
    case nameDetail
    case category
    case state
    case location
    case purchaseDate
    case purchasePlace
    case warrantyExpireAt
    case price
    case quantity
    case memo
    
    // 속성 이름 반환 메서드
    var title: String {
        switch self {
        case .nameDetail: return "Detailed name"
        case .category: return "Category"
        case .state: return "State"
        case .location: return "Location"
        case .purchaseDate: return "Purchase date"
        case .purchasePlace: return "Purchase place"
        case .warrantyExpireAt: return "Warranty expiration"
        case .price: return "Price"
        case .quantity: return "Quantity"
        case .memo: return "Memo"
        }
    }
    // 태그 타입 여부 반환 메서드
    var isTagType: Bool {
        switch self {
        case .category, .state, .location: return true
        default: return false
        }
    }
    // SortingOption -> ItemProperty 변환 메서드
    static func from(sortingOption: SortingOption) -> ItemProperty? {
        switch sortingOption {
        case .nameDetail: return .nameDetail
        case .purchaseDate: return .purchaseDate
        case .purchasePlace: return .purchasePlace
        case .expireDate: return .warrantyExpireAt
        case .price: return .price
        case .quantity: return .quantity
        default: return nil
        }
    }
    // FilterOption -> ItemProperty 변환 메서드
    static func from(filterOption: FilterOption) -> ItemProperty {
        switch filterOption {
        case .category: return .category
        case .location: return .location
        case .itemState: return .state
        }
    }
}
