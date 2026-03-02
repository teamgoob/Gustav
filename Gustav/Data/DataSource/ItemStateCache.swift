//
//  ItemStateCache.swift
//  Gustav
//
//  Created by 박선린 on 2/25/26.
//

import Foundation

// MARK: - ItemStateCache
// ItemStateRepository에서 사용할 캐시
// Thread-Safe를 위해 actor로 선언
actor ItemStateCache {
    // 캐시 저장소
    private var storage: [UUID: ItemState] = [:]
    
    // 아이템 상태 목록 저장
    func save(_ itemStates: [ItemState]) {
        storage = Dictionary(uniqueKeysWithValues: itemStates.map { ($0.id, $0) })
    }
    
    // 아이템 상태 목록 전체 불러오기
    func getAll() -> [ItemState] {
        storage.values.sorted { $0.indexKey < $1.indexKey }
    }
    
    // 단일 아이템 상태 불러오기
    func get(id: UUID) -> ItemState? {
        storage[id]
    }
    
    // 아이템 상태 추가
    func insert(_ itemState: ItemState) {
        storage[itemState.id] = itemState
    }
    
    // 아이템 상태 삭제
    func remove(id: UUID) {
        storage.removeValue(forKey: id)
    }
    
    // 아이템 상태 이름 변경
    func updateItemState(itemState: ItemState) {
        guard let _ = storage[itemState.id] else { return }
        storage[itemState.id] = itemState
    }
    
    // 아이템 상태 순서 변경
    func updateOrder(order: [UUID]) {
        for (index, id) in order.enumerated() {
            guard let itemState = storage[id] else { continue }
            
            let newItemState = ItemState(
                id: itemState.id,
                workspaceId: itemState.workspaceId,
                indexKey: itemState.indexKey,
                name: itemState.name,
                color: itemState.color
            )
            
            storage[id] = newItemState
        }
    }
    
    // 캐시 비우기
    func clear() {
        storage.removeAll()
    }
}
