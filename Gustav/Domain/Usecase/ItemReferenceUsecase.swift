//
//  ItemReferenceUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - ItemReference를 생성하는 Usecase
protocol ItemReferenceUsecaseProtocol {
    // ItemReference 생성
    func createItemReference(item: Item) async -> DomainResult<ItemReference>
}

final class ItemReferenceUsecase: ItemReferenceUsecaseProtocol {
    func createItemReference(item: Item) async -> DomainResult<ItemReference> {
        <#code#>
    }
}
