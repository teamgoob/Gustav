//
//  PresetDetailUsecaseProtocol.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//


import Foundation

// MARK: - PresetDetailUsecaseProtocol
protocol PresetDetailUsecaseProtocol {
    func fetchPresetDetailContext() async -> PresetDetailContext
}

// MARK: - TestPresetDetailUsecase
final class TestPresetDetailUsecase: PresetDetailUsecaseProtocol {
    
    func fetchPresetDetailContext() async -> PresetDetailContext {
        let categoryID = UUID()
        let locationID = UUID()
        let itemStateID = UUID()
        let workspaceID = UUID()
        
        let preset = ViewPreset(
            id: UUID(),
            workspaceId: workspaceID,
            name: "적당히 긴 프리셋명",
            viewType: 0,
            sortingOption: .name(order: .ascending),
            filters: [
                .category(categoryID),
                .location(locationID),
                .itemState(itemStateID)
            ],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return PresetDetailContext(
            preset: preset,
            categoryNameByID: [
                categoryID: "전자기기"
            ],
            locationNameByID: [
                locationID: "거실"
            ],
            itemStateNameByID: [
                itemStateID: "사용 중"
            ]
        )
    }
}
