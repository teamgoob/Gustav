//
//  TestItemReferenceUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/4/1.
//

import Foundation

// MARK: - TestItemReferenceUsecase
// UI 테스트용 ItemReferenceUsecase
final class TestItemReferenceUsecase: ItemReferenceUsecaseProtocol {
    func createAllItemReferences(workspaceId: UUID) async -> DomainResult<[ItemReference]> {
        return .success([])
    }
    
    func createItemReferences(workspaceId: UUID, items: [Item]) async -> DomainResult<[ItemReference]> {
        return .success([
            ItemReference(
                item: Item(id: UUID(), workspaceId: UUID(), indexKey: 0, name: "MacBook Pro", nameDetail: "14 Inches M3", categoryId: UUID(), stateId: nil, locationId: nil, purchaseDate: Date(), purchasePlace: "Apple Store", warrantyExpireAt: Date(), price: 3200000, quantity: 1, memo: "For work", createdAt: Date(), updatedAt: Date()),
                category: Category(id: UUID(), workspaceId: UUID(), parentId: nil, indexKey: 0, name: "Electronics", color: .red),
                location: nil,
                state: nil
            ),
            ItemReference(
                item: Item(id: UUID(), workspaceId: UUID(), indexKey: 1, name: "iPad", nameDetail: "Air", categoryId: UUID(), stateId: nil, locationId: nil, purchaseDate: Date(), purchasePlace: "Apple Store", warrantyExpireAt: Date(), price: 900000, quantity: 1, memo: nil, createdAt: Date(), updatedAt: Date()),
                category: Category(id: UUID(), workspaceId: UUID(), parentId: nil, indexKey: 0, name: "Electronics", color: .red),
                location: nil,
                state: nil
            ),
            ItemReference(
                item: Item(id: UUID(), workspaceId: UUID(), indexKey: 2, name: "Chair", nameDetail: nil, categoryId: UUID(), stateId: nil, locationId: nil, purchaseDate: Date(), purchasePlace: "IKEA", warrantyExpireAt: Date(), price: 300000, quantity: 1, memo: nil, createdAt: Date(), updatedAt: Date()),
                category: Category(id: UUID(), workspaceId: UUID(), parentId: nil, indexKey: 1, name: "Furniture", color: .brown),
                location: nil,
                state: nil
            ),
            ItemReference(
                item: Item(id: UUID(), workspaceId: UUID(), indexKey: 3, name: "Desk", nameDetail: nil, categoryId: UUID(), stateId: nil, locationId: nil, purchaseDate: Date(), purchasePlace: "IKEA", warrantyExpireAt: Date(), price: 600000, quantity: 1, memo: nil, createdAt: Date(), updatedAt: Date()),
                category: Category(id: UUID(), workspaceId: UUID(), parentId: nil, indexKey: 1, name: "Furniture", color: .brown),
                location: nil,
                state: nil
            ),
            ItemReference(
                item: Item(id: UUID(), workspaceId: UUID(), indexKey: 4, name: "Teddy Bear", nameDetail: nil, categoryId: nil, stateId: nil, locationId: nil, purchaseDate: nil, purchasePlace: nil, warrantyExpireAt: nil, price: 50000, quantity: 1, memo: nil, createdAt: Date(), updatedAt: Date()),
                category: nil,
                location: nil,
                state: nil
            )
        ])
    }
}
