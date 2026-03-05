//
//  CategoryCache.swift
//  Gustav
//
//  Created by 박선린 on 2/25/26.
//

import Foundation

// MARK: - CategoryCache
// CategoryRepository에서 사용할 캐시
// Thread-Safe를 위해 actor로 선언
actor CategoryCache {
    // 캐시 저장소
    private var storage: [UUID: Category] = [:]
    
    // 카테고리 목록 저장
    func save(_ workspaces: [Category]) {
        storage = Dictionary(uniqueKeysWithValues: workspaces.map { ($0.id, $0) })
    }
    
    // 카테고리 목록 전체 불러오기
    func getAll() -> [Category] {
        storage.values.sorted { $0.indexKey < $1.indexKey }
    }
    
    // 단일 카테고리 불러오기
    func get(id: UUID) -> Category? {
        storage[id]
    }
    
    // 카테고리 추가
    func insert(_ category: Category) {
        storage[category.id] = category
    }
    
    // 카테고리 삭제
    func remove(id: UUID) {
        storage.removeValue(forKey: id)
    }
    
    // 카테고리 변경
    func updateCategory(category: Category) {
        guard let _ = storage[category.id] else { return }
        storage[category.id] = category
    }
    
    // 카테고리 순서 변경
    func updateOrder(order: [UUID]) {
        for (index, id) in order.enumerated() {
            guard let category = storage[id] else { continue }
            
            let newCategory = Category(
                id: category.id,
                workspaceId: category.workspaceId,
                parentId: category.parentId,
                indexKey: index,
                name: category.name,
                color: category.color
            )
            
            storage[id] = newCategory
        }
    }
    
    // 캐시 비우기
    func clear() {
        storage.removeAll()
    }
}
