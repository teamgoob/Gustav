//
//  DomainConvertible.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - DomainConvertible 프로토콜
// DTO -> Entity 변환을 위한 프로토콜
protocol DomainConvertible {
    associatedtype DomainType
    func toDomain() -> DomainType
}

// ItemDTO -> Item 변환 메서드 정의
extension ItemDTO: DomainConvertible {
    typealias DomainType = Item
    
    func toDomain() -> Item {
        Item(
            id: id,
            workspaceId: workspaceId,
            indexKey: indexKey,
            name: name,
            nameDetail: nameDetail,
            categoryId: categoryId,
            stateId: stateId,
            locationId: locationId,
            purchaseDate: purchaseDate,
            purchasePlace: purchasePlace,
            warrantyExpireAt: warrantyExpireAt,
            price: price,
            quantity: quantity,
            memo: memo,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// WorkspaceDTO -> Workspace 변환 메서드 정의
extension WorkspaceDTO: DomainConvertible {
    typealias DomainType = Workspace
    
    func toDomain() -> Workspace {
        Workspace(
            id: id,
            userId: userId,
            indexKey: indexKey,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
