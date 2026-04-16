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
    private var storage: [UUID: [Category]] = [:]

    // 저장
    func save(categories: [Category], for workspaceId: UUID) {
        storage[workspaceId] = categories
    }

    // 전체 조회
    func getAll(for workspaceId: UUID) -> [Category] {
        storage[workspaceId] ?? []
    }

    // 단일 조회
    func get(id: UUID, workspaceId: UUID) -> Category? {
        storage[workspaceId]?.first { $0.id == id }
    }

    // 추가
    func insert(_ category: Category) {
        var list = storage[category.workspaceId] ?? []
        list.append(category)
        storage[category.workspaceId] = list
    }

    // 삭제
    func remove(id: UUID, workspaceId: UUID) {
        var list = storage[workspaceId] ?? []
        list.removeAll { $0.id == id }
        storage[workspaceId] = list
    }

    // 업데이트
    func update(_ category: Category) {
        var list = storage[category.workspaceId] ?? []
        if let index = list.firstIndex(where: { $0.id == category.id }) {
            list[index] = category
            storage[category.workspaceId] = list
        }
    }

    // 순서 변경
    func updateOrder(workspaceId: UUID, order: [UUID]) {
        guard let list = storage[workspaceId] else { return }

        var newList: [Category] = []
        for (index, id) in order.enumerated() {
            guard let category = list.first(where: { $0.id == id }) else { continue }

            let updated = Category(
                id: category.id,
                workspaceId: category.workspaceId,
                parentId: category.parentId,
                indexKey: index,
                name: category.name,
                color: category.color
            )
            newList.append(updated)
        }

        storage[workspaceId] = newList
    }

    // 특정 workspace 캐시 삭제
    func clear(workspaceId: UUID) {
        storage.removeValue(forKey: workspaceId)
    }

    // 전체 삭제
    func clearAll() {
        storage.removeAll()
    }
}
