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

// CategoryDTO -> Category 변환 메서드 정의
extension CategoryDTO: DomainConvertible {
    typealias DomainType = Category
    
    func toDomain() -> Category {
        let colorValue: Int = self.color ?? 0
        let tagColor: TagColor = TagColor(rawValue: colorValue) ?? .darkGray
        return Category(
            id: self.id,
            workspaceId: self.workspaceId,
            parentId: self.parentId,
            indexKey: self.indexKey,
            name: self.name,
            color: tagColor
        )
    }
}

// ItemStateDTO -> ItemState 변환 메서드 정의
extension ItemStateDTO: DomainConvertible {
    typealias DomainType = ItemState
    func toDomain() -> ItemState {
        let tagColor: TagColor = TagColor(rawValue: self.color) ?? .darkGray
        return ItemState(
            id: self.id,
            workspaceId: self.workspaceId,
            indexKey: self.indexKey,
            name: self.name,
            color: tagColor
        )
    }
}

// LocationDTO -> Location 변환 메서드 정의
extension LocationDTO: DomainConvertible {
    typealias DomainType = Location
    func toDomain() -> Location {
        let tagColor: TagColor = TagColor(rawValue: self.color) ?? .darkGray
        return Location(
            id: self.id,
            workspaceId: self.workspaceId,
            indexKey: self.indexKey,
            name: self.name,
            color: tagColor)
    }
}

// ViewPresetDTO -> ViewPreset 변환 메서드 정의
extension ViewPresetDTO: DomainConvertible {
    typealias Domain = ViewPreset
    func toDomain() -> ViewPreset {
        return ViewPreset(
            id: self.id,
            workspaceId: self.workspaceId,
            name: self.name,
            viewType: self.viewType,
            sortingOption: self.sortingOption,
            filters: self.filters,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt)
    }
}

// Auth DTO -> Auth 변환 메서드 정의 
extension AuthDTO: DomainConvertible {
    typealias DomainType = AuthSession

    func toDomain() -> AuthSession {
        // provider 문자열 → 도메인 enum으로 변환
        let domainProvider = AuthProvider(rawValue: provider) ?? .unknown

        return AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: userId,
            expiresAt: expiresAt,
            provider: domainProvider
        )
    }
}


extension ProfileDTO: DomainConvertible {
    typealias DomainType = Profile

    func toDomain() -> Profile {
        Profile(
            id: id,
            displayName: name,
            email: email,
            isPrivateEmail: isPrivateEmail,
            createdAt: createdAt,
            updatedAt: updatedAt,
            profileImageUrl: profileImageUrl
        )
    }
}
