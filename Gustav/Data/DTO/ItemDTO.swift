//
//  ItemDTO.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - ItemDTO
struct ItemDTO: Codable {
    let id: UUID
    let workspaceId: UUID
    let indexKey: Int
    let name: String
    let nameDetail: String?
    let categoryId: UUID?
    let stateId: UUID?
    let locationId: UUID?
    let purchaseDate: Date?
    let purchasePlace: String?
    let warrantyExpireAt: Date?
    let price: Int?
    let quantity: Int?
    let memo: String?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case workspaceId = "workspace_id"
        case indexKey = "index_key"
        case name
        case nameDetail = "name_detail"
        case categoryId = "category_id"
        case stateId = "state_id"
        case locationId = "location_id"
        case purchaseDate = "purchase_date"
        case purchasePlace = "purchase_place"
        case warrantyExpireAt = "warranty_expire_at"
        case price
        case quantity
        case memo
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Extensions: ItemDTO -> Item 변환
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
