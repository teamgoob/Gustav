//
//  CategoryRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
//import Foundation
//
//final class ItemStateRepository: ItemStateRepositoryProtocol {
//    
//    let dataSource: ItemStateDataSourceProtocol
//    
//    init(dataSource remote: ItemStateDataSourceProtocol) {
//        self.dataSource = remote
//    }
//    
//    func fetchItemStates(workspaceId: UUID) async -> RepositoryResult<[ItemState]> {
//        <#code#>
//    }
//    
//    func fetchItemState(id: UUID) async -> RepositoryResult<ItemState> {
//        <#code#>
//    }
//    
//    func createItemState(workspaceId: UUID, name: String, color: TagColor) async -> RepositoryResult<ItemState> {
//        <#code#>
//    }
//    
//    func updateItemState(id: UUID, itemState: ItemState) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//    func deleteItemState(id: UUID) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//}
