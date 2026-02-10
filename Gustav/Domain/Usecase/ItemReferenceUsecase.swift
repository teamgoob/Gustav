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
    func createItemReference(item: Item) async -> DomainResult<ItemReference>
}

struct ItemReferenceUsecase: ItemReferenceUsecaseProtocol {
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
    
    // 단일 아이템 객체로 ItemReference 객체 생성 - *각 레포지토리에는 단일 fetch가 구현되어 있지 않아 비효율적*
    func createItemReference(item: Item) async -> DomainResult<ItemReference> {
        // 1) ItemReference에 필요한 데이터들
        /// 1) 워크스페이스에 사용되는 카테고리 fetch
        async let categoryResult = categoryRepository
            .fetchCategories(workspaceId: item.workspaceId)
            .toDomainResult()

        /// 2) 워크스페이스에 사용되는 로케이션 fetch
        async let locationResult = locationRepository
            .fetchLocations(workspaceId: item.workspaceId)
            .toDomainResult()

        /// 3)
        async let itemStateResult = itemStateRepository
            .fetchItemStates(workspaceId: item.workspaceId)
            .toDomainResult()

        // 2) 결과 체크
        /// 결과를 하나씩 꺼내면서 실패면 즉시 반환(Strict 정책)
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

        // 3) item이 들고 있는 참조 ID로 목록에서 매칭
        let matchedCategory: Category? = {
            guard let categoryId = item.categoryId else { return nil }
            return categories.first { $0.id == categoryId }
        }()

        let matchedLocation: Location? = {
            guard let locationId = item.locationId else { return nil }
            return locations.first { $0.id == locationId }
        }()

        let matchedState: ItemState? = {
            guard let stateId = item.stateId else { return nil }
            return states.first { $0.id == stateId }
        }()

        // 4) 최종으로 “화면에서 쓰기 좋은 묶음”을 생성해서 성공으로 반환
        let itemReference = ItemReference(
            item: item,
            category: matchedCategory,
            location: matchedLocation,
            state: matchedState
        )

        return .success(itemReference)
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

        items.forEach { item in
            
            // 3) item이 들고 있는 참조 ID로 목록에서 매칭
            let matchedCategory: Category? = {
                guard let categoryId = item.categoryId else { return nil }
                return categories.first { $0.id == categoryId }
            }()
            
            let matchedLocation: Location? = {
                guard let locationId = item.locationId else { return nil }
                return locations.first { $0.id == locationId }
            }()
            
            let matchedState: ItemState? = {
                guard let stateId = item.stateId else { return nil }
                return states.first { $0.id == stateId }
            }()
            
            // 4) 최종으로 “화면에서 쓰기 좋은 묶음”을 생성해서 성공으로 반환
            let itemReference = ItemReference(
                item: item,
                category: matchedCategory,
                location: matchedLocation,
                state: matchedState
            )
        }

        return .success(itemReferences)
    }

}
