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
    // 캐시 저장소
    private var storage: [UUID: Location] = [:]
    
    // 장소 목록 저장
    func save(_ location: [Location]) {
        storage = Dictionary(uniqueKeysWithValues: location.map { ($0.id, $0) })
    }
    
    // 장소 목록 전체 불러오기
    func getAll() -> [Location] {
        storage.values.sorted { $0.indexKey < $1.indexKey }
    }
    
    // 단일 장소 불러오기
    func get(id: UUID) -> Location? {
        storage[id]
    }
    
    // 장소 추가
    func insert(_ location: Location) {
        storage[location.id] = location
    }
    
    // 장소 삭제
    func remove(id: UUID) {
        storage.removeValue(forKey: id)
    }
    
    // 장소 수정
    func updateLocation(location: Location) {
        guard let _ = storage[location.id] else { return }
        storage[location.id] = location
    }
    
    // 장소 순서 변경
    func updateOrder(order: [UUID]) {
        for (index, id) in order.enumerated() {
            guard let location = storage[id] else { continue }
            
            let newLocation = Location(
                id: location.id,
                workspaceId: location.workspaceId,
                indexKey: index,
                name: location.name,
                color: location.color
            )
            storage[location.id] = newLocation
        }
    }
    
    // 캐시 비우기
    func clear() {
        storage.removeAll()
    }
}
