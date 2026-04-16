//
//  TestViewPresetUsecase.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import Foundation


final class TestViewPresetUsecase: ViewPresetUsecaseProtocol {
    func createViewPreset(workspaceId: UUID, preset: ViewPreset) async -> DomainResult<ViewPreset> {
        .success(preset)

    }
    
    func updateViewPreset(id: UUID, preset: ViewPreset) async -> DomainResult<Void> {
        .success(())

    }
    
    func deleteViewPreset(id: UUID) async -> DomainResult<Void> {
        .success(())

    }
    
    func fetchViewPresets(workspaceId: UUID) async -> DomainResult<[ViewPreset]> {
        return .success([
            ViewPreset(
                id: UUID(),
                workspaceId: workspaceId,
//                indexKey: 0,
                name: "애플 신제품",
                viewType: 0,
                sortingOption: .name(order: .ascending),
                filters: [],
                createdAt: Date(),
                updatedAt: Date()
            ),
            ViewPreset(
                id: UUID(),
                workspaceId: workspaceId,
//                indexKey: 1,
                name: "삼성 중고",
                viewType: 0,
                sortingOption: .createdAt(order: .descending),
                filters: [],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date()
            ),
            
            ViewPreset(
                id: UUID(),
                workspaceId: workspaceId,
//                indexKey: 2,
                name: "삼성 중고2",
                viewType: 0,
                sortingOption: .createdAt(order: .descending),
                filters: [],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date()
            ),
            ViewPreset(
                id: UUID(),
                workspaceId: workspaceId,
//                indexKey: 3,
                name: "삼성 중고3",
                viewType: 0,
                sortingOption: .createdAt(order: .descending),
                filters: [],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date()
            ),
            
        ])
    }
}
