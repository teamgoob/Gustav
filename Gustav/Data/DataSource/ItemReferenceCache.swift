//
//  WorkspaceCache.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - WorkspaceCache
// WorkspaceRepository에서 사용할 캐시
// Thread-Safe를 위해 actor로 선언
actor ItemCache {
    // 캐시 저장소
    private var storage: [UUID: Item] = [:]
    
    // 아이템 목록 저장
    func save(_ item: [Item]) {
        storage = Dictionary(uniqueKeysWithValues: item.map { ($0.id, $0) })
    }
    
    // 아이템 목록 전체 불러오기
    func getAll() -> [Item] {
        storage.values.sorted { $0.indexKey < $1.indexKey }
    }
    
    // 단일 아이템 불러오기
    func get(id: UUID) -> Item? {
        storage[id]
    }
    
    // 아이템 추가
    func insert(_ item: Item) {
        storage[item.id] = item
    }
    
    // 아이템 삭제
    func remove(id: UUID) {
        storage.removeValue(forKey: id)
    }
    
    // 아이템 이름 변경
    func updateItem(item: Item) {
        guard let _ = storage[item.id] else { return }
        
        let newitem = Item(
            id: item.id,
            workspaceId: item.workspaceId,
            indexKey: item.indexKey,
            name: item.name,
            nameDetail: item.nameDetail,
            categoryId: item.categoryId,
            stateId: item.stateId,
            locationId: item.locationId,
            purchaseDate: item.purchaseDate,
            purchasePlace: item.purchasePlace,
            warrantyExpireAt: item.warrantyExpireAt,
            price: item.price,
            quantity: item.quantity,
            memo: item.memo,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
        storage[item.id] = newitem
    }
    
    // 아이템 순서 변경
    func updateOrder(order: [UUID]) {
        for (index, id) in order.enumerated() {
            guard let item = storage[id] else { continue }
            
            let newitem = Item(
                id: item.id,
                workspaceId: item.workspaceId,
                indexKey: index,
                name: item.name,
                nameDetail: item.nameDetail,
                categoryId: item.categoryId,
                stateId: item.stateId,
                locationId: item.locationId,
                purchaseDate: item.purchaseDate,
                purchasePlace: item.purchasePlace,
                warrantyExpireAt: item.warrantyExpireAt,
                price: item.price,
                quantity: item.quantity,
                memo: item.memo,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt
            )
            
            storage[id] = newitem
        }
    }
    
    // 캐시 비우기
    func clear() {
        storage.removeAll()
    }
}
