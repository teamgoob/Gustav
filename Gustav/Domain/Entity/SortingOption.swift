//
//  SortingOption.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 아이템 정렬 옵션
enum SortingOption: Codable {
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
    
    // 정렬 순서 없는 정렬 옵션만 표현하기 위한 열거형
    enum SortingOptionCase {
        case indexKey
        case name
        case nameDetail
        case purchaseDate
        case purchasePlace
        case expireDate
        case price
        case quantity
        case createdAt
        case updatedAt
    }
    
    // 정렬 옵션을 메뉴에 표시할 텍스트로 변환하는 메서드
    func toText() -> String {
        switch self {
        case .indexKey: return "Preferred Order"
        case .name: return "Name"
        case .nameDetail: return "Name Detail"
        case .purchaseDate: return "Purchase Date"
        case .purchasePlace: return "Purchase Place"
        case .expireDate: return "Expiration Date"
        case .price: return "Price"
        case .quantity: return "Quantity"
        case .createdAt: return "Created at"
        case .updatedAt: return "Updated at"
        }
    }
    
    // 정렬 순서를 메뉴에 표시할 텍스트로 변환하는 메서드
    func orderToText(isAscending: Bool) -> String {
        switch self {
        case .indexKey:
            switch isAscending {
            case true: return "Ascending Order"
            case false: return "Descending Order"
            }
        case .name:
            switch isAscending {
            case true: return "Ascending Order"
            case false: return "Descending Order"
            }
        case .nameDetail:
            switch isAscending {
            case true: return "Ascending Order"
            case false: return "Descending Order"
            }
        case .purchaseDate:
            switch isAscending {
            case true: return "Oldest First"
            case false: return "Latest First"
            }
        case .purchasePlace:
            switch isAscending {
            case true: return "Ascending Order"
            case false: return "Descending Order"
            }
        case .expireDate:
            switch isAscending {
            case true: return "Oldest First"
            case false: return "Latest First"
            }
        case .price:
            switch isAscending {
            case true: return "Lowest First"
            case false: return "Highest First"
            }
        case .quantity:
            switch isAscending {
            case true: return "Ascending Order"
            case false: return "Descending Order"
            }
        case .createdAt:
            switch isAscending {
            case true: return "Oldest First"
            case false: return "Latest First"
            }
        case .updatedAt:
            switch isAscending {
            case true: return "Oldest First"
            case false: return "Latest First"
            }
        }
    }
    
    // 정렬 순서 없는 정렬 옵션 값 반환
    var sortingOptionCase: SortingOptionCase {
        switch self {
        case .indexKey: return .indexKey
        case .name: return .name
        case .nameDetail: return .nameDetail
        case .purchaseDate: return .purchaseDate
        case .purchasePlace: return .purchasePlace
        case .expireDate: return .expireDate
        case .price: return .price
        case .quantity: return .quantity
        case .createdAt: return .createdAt
        case .updatedAt: return .updatedAt
        }
    }
    
    // 정렬 순서만 반환
    var order: SortingOrder {
        switch self {
        case .indexKey(let order),
                .name(let order),
                .nameDetail(let order),
                .purchaseDate(let order),
                .purchasePlace(let order),
                .expireDate(let order),
                .price(let order),
                .quantity(let order),
                .createdAt(let order),
                .updatedAt(let order):
            return order
        }
    }
}
