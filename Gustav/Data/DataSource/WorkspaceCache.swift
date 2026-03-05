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
actor WorkspaceCache {
    // 캐시 저장소
    private var storage: [UUID: Workspace] = [:]
    
    // 워크스페이스 목록 저장
    func save(_ workspaces: [Workspace]) {
        storage = Dictionary(uniqueKeysWithValues: workspaces.map { ($0.id, $0) })
    }
    
    // 워크스페이스 목록 전체 불러오기
    func getAll() -> [Workspace] {
        storage.values.sorted { $0.indexKey < $1.indexKey }
    }
    
    // 단일 워크스페이스 불러오기
    func get(id: UUID) -> Workspace? {
        storage[id]
    }
    
    // 워크스페이스 추가
    func insert(_ workspace: Workspace) {
        storage[workspace.id] = workspace
    }
    
    // 워크스페이스 삭제
    func remove(id: UUID) {
        storage.removeValue(forKey: id)
    }
    
    // 워크스페이스 이름 변경
    func updateName(id: UUID, name: String) {
        guard let workspace = storage[id] else { return }
        
        let newWorkspace = Workspace(id: workspace.id,
                                     userId: workspace.userId,
                                     indexKey: workspace.indexKey,
                                     name: name,
                                     createdAt: workspace.createdAt,
                                     updatedAt: workspace.updatedAt
        )
        storage[id] = newWorkspace
    }
    
    // 워크스페이스 순서 변경
    func updateOrder(order: [UUID]) {
        for (index, id) in order.enumerated() {
            guard let workspace = storage[id] else { continue }
            
            let newWorkspace = Workspace(id: workspace.id,
                                         userId: workspace.userId,
                                         indexKey: index,
                                         name: workspace.name,
                                         createdAt: workspace.createdAt,
                                         updatedAt: workspace.updatedAt
            )
            
            storage[id] = newWorkspace
        }
    }
    
    // 캐시 비우기
    func clear() {
        storage.removeAll()
    }
}
