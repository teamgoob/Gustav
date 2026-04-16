//
//  LocationCache.swift
//  Gustav
//
//  Created by 박선린 on 2/25/26.
//

import Foundation

// MARK: - LocationCache
// LocationRepository에서 사용할 캐시
// Thread-Safe를 위해 actor로 선언
actor LocationCache {
    private var storage: [UUID: [Location]] = [:]

    // 저장
    func save(locations: [Location], for workspaceId: UUID) {
        storage[workspaceId] = locations
    }

    // 전체 조회
    func getAll(for workspaceId: UUID) -> [Location] {
        storage[workspaceId] ?? []
    }

    // 단일 조회
    func get(id: UUID, workspaceId: UUID) -> Location? {
        storage[workspaceId]?.first { $0.id == id }
    }

    // 추가
    func insert(_ location: Location) {
        var list = storage[location.workspaceId] ?? []
        list.append(location)
        storage[location.workspaceId] = list
    }

    // 삭제
    func remove(id: UUID, workspaceId: UUID) {
        var list = storage[workspaceId] ?? []
        list.removeAll { $0.id == id }
        storage[workspaceId] = list
    }

    // 업데이트
    func update(_ location: Location) {
        var list = storage[location.workspaceId] ?? []
        if let index = list.firstIndex(where: { $0.id == location.id }) {
            list[index] = location
            storage[location.workspaceId] = list
        }
    }

    // 순서 변경
    func updateOrder(workspaceId: UUID, order: [UUID]) {
        guard let list = storage[workspaceId] else { return }

        var newList: [Location] = []
        for (index, id) in order.enumerated() {
            guard let location = list.first(where: { $0.id == id }) else { continue }

            let updated = Location(
                id: location.id,
                workspaceId: location.workspaceId,
                indexKey: index,
                name: location.name,
                color: location.color
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
