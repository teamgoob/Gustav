//
//  ViewPresetMapper.swift
//  Gustav
//
//  Created by kaeun on 4/6/26.
//


import Foundation

enum ViewPresetMapper {
    static func toDTO(from entity: ViewPreset) -> ViewPresetDTO {
        ViewPresetDTO(
            id: entity.id,
            workspaceId: entity.workspaceId,
            name: entity.name,
            viewType: entity.viewType,
            sortingOption: sortingOptionValue(from: entity.sortingOption),
            sortingOrder: sortingOrderValue(from: entity.sortingOption),
            categoryId: extractCategoryID(from: entity.filters),
            stateId: extractStateID(from: entity.filters),
            locationId: extractLocationID(from: entity.filters),
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }

    static func toEntity(from dto: ViewPresetDTO) -> ViewPreset {
        ViewPreset(
            id: dto.id,
            workspaceId: dto.workspaceId,
//            indexKey: 0,
            name: dto.name,
            viewType: dto.viewType,
            sortingOption: makeSortingOption(
                sortingOption: dto.sortingOption,
                sortingOrder: dto.sortingOrder
            ),
            filters: makeFilters(
                categoryId: dto.categoryId,
                stateId: dto.stateId,
                locationId: dto.locationId
            ),
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
}

private extension ViewPresetMapper {
    static func extractCategoryID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .category(let id) = filter {
                return id
            }
        }
        return nil
    }

    static func extractStateID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .itemState(let id) = filter {
                return id
            }
        }
        return nil
    }

    static func extractLocationID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .location(let id) = filter {
                return id
            }
        }
        return nil
    }

    static func makeFilters(
        categoryId: UUID?,
        stateId: UUID?,
        locationId: UUID?
    ) -> [FilterOption] {
        var filters: [FilterOption] = []

        if let categoryId {
            filters.append(.category(categoryId))
        }

        if let stateId {
            filters.append(.itemState(stateId))
        }

        if let locationId {
            filters.append(.location(locationId))
        }

        return filters
    }
}

private extension ViewPresetMapper {
    static func sortingOptionValue(from option: SortingOption) -> Int {
        switch option {
        case .indexKey: return 0
        case .name: return 1
        case .nameDetail: return 2
        case .purchaseDate: return 3
        case .purchasePlace: return 4
        case .expireDate: return 5
        case .price: return 6
        case .quantity: return 7
        case .createdAt: return 8
        case .updatedAt: return 9
        }
    }

    static func sortingOrderValue(from option: SortingOption) -> Int {
        switch option {
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
            return order.rawValue
        }
    }

    static func makeSortingOption(
        sortingOption: Int,
        sortingOrder: Int
    ) -> SortingOption {
        let order = SortingOrder(rawValue: sortingOrder) ?? .ascending

        switch sortingOption {
        case 0: return .indexKey(order: order)
        case 1: return .name(order: order)
        case 2: return .nameDetail(order: order)
        case 3: return .purchaseDate(order: order)
        case 4: return .purchasePlace(order: order)
        case 5: return .expireDate(order: order)
        case 6: return .price(order: order)
        case 7: return .quantity(order: order)
        case 8: return .createdAt(order: order)
        case 9: return .updatedAt(order: order)
        default: return .indexKey(order: order)
        }
    }
}
