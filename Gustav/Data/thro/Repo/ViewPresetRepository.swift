//
//  ViewPresetRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
//import Foundation
//
//final class ViewPresetRepository: ViewPresetRepositoryProtocol {
//    
//    private let dataSource: ViewPresetDataSourceProtocol 
//    
//    init(dataSource remote: ViewPresetDataSourceProtocol) {
//        self.dataSource = remote
//    }
//    
//    func fetchViewPresets(workspaceId: UUID) async -> RepositoryResult<[ViewPreset]> {
//        <#code#>
//    }
//    
//    func createViewPreset(workspaceId: UUID, preset: ViewPreset) async -> RepositoryResult<ViewPreset> {
//        <#code#>
//    }
//    
//    func updateViewPreset(id: UUID, preset: ViewPreset) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//    func deleteViewPreset(id: UUID) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//}
