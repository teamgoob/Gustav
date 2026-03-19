//
//  PresetDetailViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import Foundation

// MARK: - PresetDetailContext
// 디테일 화면에 필요한 데이터를 UseCase에서 묶어서 전달하기 위한 구조
struct PresetDetailContext {
    let preset: ViewPreset
    let categoryNameByID: [UUID: String]
    let locationNameByID: [UUID: String]
    let itemStateNameByID: [UUID: String]
}

// MARK: - PresetDetailViewModel
final class PresetDetailViewModel {
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case didTapViewType
        case didTapSortBy
        case didTapSortOrder
        case didTapCategory
        case didTapLocation
        case didTapItemStatus
        case didTapMore
    }
    
    // MARK: - Output
    struct Output {
        let title: String
        let viewType: String
        let sortingOption: String?
        let sortingOrder: String?
        let category: String?
        let location: String?
        let itemStatus: String?
    }
    
    // MARK: - Route
    enum Route {
        case showViewTypeSelection
        case showSortBySelection
        case showSortOrderSelection
        case showCategorySelection
        case showLocationSelection
        case showItemStatusSelection
        case showMoreMenu
    }
    
    // MARK: - Closures
    var onDisplay: ((Output) -> Void)?
    var onNavigation: ((Route) -> Void)?
    
    // MARK: - Properties
    private let context: PresetDetailContext
    
    // MARK: - Init
    init(context: PresetDetailContext) {
        self.context = context
    }
}

// MARK: - External Methods
extension PresetDetailViewModel {
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            notifyOutput()
            
        case .didTapViewType:
            onNavigation?(.showViewTypeSelection)
            
        case .didTapSortBy:
            onNavigation?(.showSortBySelection)
            
        case .didTapSortOrder:
            onNavigation?(.showSortOrderSelection)
            
        case .didTapCategory:
            onNavigation?(.showCategorySelection)
            
        case .didTapLocation:
            onNavigation?(.showLocationSelection)
            
        case .didTapItemStatus:
            onNavigation?(.showItemStatusSelection)
            
        case .didTapMore:
            onNavigation?(.showMoreMenu)
        }
    }
}

// MARK: - Private Logic
private extension PresetDetailViewModel {
    func notifyOutput() {
        let output = Output(
            title: context.preset.name,
            viewType: mapViewTypeToText(context.preset.viewType),
            sortingOption: mapSortingOptionToText(context.preset.sortingOption),
            sortingOrder: mapSortingOrderToText(context.preset.sortingOption),
            category: mapCategoryText(from: context.preset.filters),
            location: mapLocationText(from: context.preset.filters),
            itemStatus: mapItemStatusText(from: context.preset.filters)
        )
        
        onDisplay?(output)
    }
    
    func mapViewTypeToText(_ viewType: Int) -> String {
        switch viewType {
        case 0:
            return "기본"
        default:
            return "기본"
        }
    }
    
    func mapSortingOptionToText(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        
        switch sortingOption {
        case .indexKey:
            return "기본순"
        case .name:
            return "이름"
        case .nameDetail:
            return "상세 이름"
        case .purchaseDate:
            return "구매일"
        case .purchasePlace:
            return "구매처"
        case .expireDate:
            return "보증 만료일"
        case .price:
            return "가격"
        case .quantity:
            return "수량"
        case .createdAt:
            return "생성일"
        case .updatedAt:
            return "수정일"
        }
    }
    
    func mapSortingOrderToText(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        
        switch sortingOption {
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
            return mapSortingOrderText(order)
        }
    }
    
    func mapSortingOrderText(_ order: SortingOrder) -> String {
        switch order {
        case .ascending:
            return "오름차순"
        case .descending:
            return "내림차순"
        }
    }
    
    func extractCategoryID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .category(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    func extractLocationID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .location(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    func extractItemStateID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .itemState(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    func mapCategoryText(from filters: [FilterOption]) -> String? {
        guard let id = extractCategoryID(from: filters) else { return nil }
        return context.categoryNameByID[id]
    }
    
    func mapLocationText(from filters: [FilterOption]) -> String? {
        guard let id = extractLocationID(from: filters) else { return nil }
        return context.locationNameByID[id]
    }
    
    func mapItemStatusText(from filters: [FilterOption]) -> String? {
        guard let id = extractItemStateID(from: filters) else { return nil }
        return context.itemStateNameByID[id]
    }
}
