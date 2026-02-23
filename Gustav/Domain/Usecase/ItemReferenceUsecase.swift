//
//  ItemReferenceUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - ItemReference를 생성하는 Usecase
protocol ItemReferenceUsecaseProtocol {
    // ItemReference 생성
    func createItemsReference(workspaceId: UUID) async -> DomainResult<[ItemReference]>
}

final class ItemReferenceUsecase: ItemReferenceUsecaseProtocol {
    let itemRepository: ItemRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let locationRepository: LocationRepositoryProtocol
    let itemStateRepository: ItemStateRepositoryProtocol
    
    init(itemRepository: ItemRepositoryProtocol, categoryRepository: CategoryRepositoryProtocol, locationRepository: LocationRepositoryProtocol, itemStateRepository: ItemStateRepositoryProtocol) {
        self.itemRepository = itemRepository
        self.categoryRepository = categoryRepository
        self.locationRepository = locationRepository
        self.itemStateRepository = itemStateRepository
    }
    
    // 워크스페이스 아이디로 모든 아이템을 ItemReference로 생성하여 배열로 반환
    func createItemsReference(workspaceId: UUID) async -> DomainResult<[ItemReference]> {
        var itemReferences: [ItemReference] = []
        
        // 1) ItemReference에 필요한 데이터들
        /// 1)  워크스페이스에 존재하는 아이템  fetch
        async let itemsResult = itemRepository
            .fetchItems(workspaceId: workspaceId)
            .toDomainResult()
        /// 2) 워크스페이스에 사용되는 카테고리 fetch
        async let categoryResult = categoryRepository
            .fetchCategories(workspaceId: workspaceId)
            .toDomainResult()

        /// 3) 워크스페이스에 사용되는 로케이션 fetch
        async let locationResult = locationRepository
            .fetchLocations(workspaceId: workspaceId)
            .toDomainResult()

        /// 4)
        async let itemStateResult = itemStateRepository
            .fetchItemStates(workspaceId: workspaceId)
            .toDomainResult()

        // 2) 결과 체크
        /// 결과를 하나씩 꺼내면서 실패면 즉시 반환(Strict 정책)
        let items: [Item]
        switch await itemsResult {
        case .success(let value):
            items = value
        case .failure(let error):
            return .failure(error)
        }
        
        let categories: [Category]
        switch await categoryResult {
        case .success(let value):
            categories = value
        case .failure(let error):
            return .failure(error)
        }

        let locations: [Location]
        switch await locationResult {
        case .success(let value):
            locations = value
        case .failure(let error):
            return .failure(error)
        }

        let states: [ItemState]
        switch await itemStateResult {
        case .success(let value):
            states = value
        case .failure(let error):
            return .failure(error)
        }
        
        let itemsDic: [UUID: Item] = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        let categoriesDic: [UUID: Category] = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        let locationsDic: [UUID: Location] = Dictionary(uniqueKeysWithValues: locations.map { ($0.id, $0) })
        let statesDic: [UUID: ItemState] = Dictionary(uniqueKeysWithValues: states.map { ($0.id, $0) })
        
        items.forEach { item in
            // 4) 최종으로 “화면에서 쓰기 좋은 묶음”을 생성해서 성공으로 반환
            itemReferences.append(
                ItemReference(
                    item: item,
                    category: item.categoryId.flatMap { categoriesDic[$0] },
                    location: item.locationId.flatMap { locationsDic[$0] },
                    state: item.stateId.flatMap { statesDic[$0] }
                )
            )
        }

        return .success(itemReferences)
    }
}
