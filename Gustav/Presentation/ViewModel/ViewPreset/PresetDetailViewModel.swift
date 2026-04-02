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
        case showOptionPopup(OptionPopupRoute)
        case showMoreMenu
    }
    
    struct OptionPopupRoute {
        let title: String
        let items: [OptionPopupItem]
        let selectedID: String?
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
            onNavigation?(.showOptionPopup(makeViewTypePopupRoute()))

        case .didTapSortBy:
            onNavigation?(.showOptionPopup(makeSortByPopupRoute()))

        case .didTapSortOrder:
            onNavigation?(.showOptionPopup(makeSortOrderPopupRoute()))

        case .didTapCategory:
            onNavigation?(.showOptionPopup(makeCategoryPopupRoute()))

        case .didTapLocation:
            onNavigation?(.showOptionPopup(makeLocationPopupRoute()))

        case .didTapItemStatus:
            onNavigation?(.showOptionPopup(makeItemStatePopupRoute()))

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
            return "Basic"
        default:
            return "Basic"
        }
    }
    
    func mapSortingOptionToText(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        
        switch sortingOption {
        case .indexKey:
            return "Basic"
        case .name:
            return "Name"
        case .nameDetail:
            return "Detail Name"
        case .purchaseDate:
            return "Purchase Date"
        case .purchasePlace:
            return "Purchase Place"
        case .expireDate:
            return "Expire Date"
        case .price:
            return "Price"
        case .quantity:
            return "Quantity"
        case .createdAt:
            return "Created At"
        case .updatedAt:
            return "Updated At"
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
            return "Ascending"
        case .descending:
            return "Descending"
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
    
    func makeCategoryPopupRoute() -> OptionPopupRoute {
        let items = context.categoryNameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                OptionPopupItem(
                    id: key.uuidString,
                    title: value
                )
            }

        let selectedID = extractCategoryID(from: context.preset.filters)?.uuidString

        return OptionPopupRoute(
            title: "Category",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeLocationPopupRoute() -> OptionPopupRoute {
        let items = context.locationNameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                OptionPopupItem(
                    id: key.uuidString,
                    title: value
                )
            }

        let selectedID = extractLocationID(from: context.preset.filters)?.uuidString

        return OptionPopupRoute(
            title: "Location",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeItemStatePopupRoute() -> OptionPopupRoute {
        let items = context.itemStateNameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                OptionPopupItem(
                    id: key.uuidString,
                    title: value
                )
            }

        let selectedID = extractItemStateID(from: context.preset.filters)?.uuidString

        return OptionPopupRoute(
            title: "Item State",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeSortByPopupRoute() -> OptionPopupRoute {
        let options = availableSortingOptions()

        let items = options.map {
            OptionPopupItem(
                id: sortingOptionID($0),
                title: mapSortingOptionToText($0) ?? ""
            )
        }

        let selectedID = sortingOptionID(context.preset.sortingOption)

        return OptionPopupRoute(
            title: "Sort By",
            items: items,
            selectedID: selectedID
        )
    }
    
    func availableSortingOptions() -> [SortingOption] {
        [
            .indexKey(order: .ascending),
            .name(order: .ascending),
            .nameDetail(order: .ascending),
            .purchaseDate(order: .ascending),
            .purchasePlace(order: .ascending),
            .expireDate(order: .ascending),
            .price(order: .ascending),
            .quantity(order: .ascending),
            .createdAt(order: .ascending),
            .updatedAt(order: .ascending)
        ]
    }
    
    func sortingOptionID(_ sortingOption: SortingOption) -> String {
        switch sortingOption {
        case .indexKey:
            return "indexKey"
        case .name:
            return "name"
        case .nameDetail:
            return "nameDetail"
        case .purchaseDate:
            return "purchaseDate"
        case .purchasePlace:
            return "purchasePlace"
        case .expireDate:
            return "expireDate"
        case .price:
            return "price"
        case .quantity:
            return "quantity"
        case .createdAt:
            return "createdAt"
        case .updatedAt:
            return "updatedAt"
        }
    }
    
    func makeViewTypePopupRoute() -> OptionPopupRoute {
        let items = [
            OptionPopupItem(id: "0", title: "Basic")
        ]
        let selectedID = String(context.preset.viewType)
        return OptionPopupRoute(
            title: "View Type",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeSortOrderPopupRoute() -> OptionPopupRoute {
        let items = [
            OptionPopupItem(id: "asc", title: "Ascending"),
            OptionPopupItem(id: "desc", title: "Descending")
        ]

        let sortingOption = context.preset.sortingOption
        let selectedID: String

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
            selectedID = order == .ascending ? "asc" : "desc"
        }

        return OptionPopupRoute(
            title: "Sort Order",
            items: items,
            selectedID: selectedID
        )
    }
}
