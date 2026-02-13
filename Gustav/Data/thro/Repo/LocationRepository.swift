//
//  LocationRepository.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
//import Foundation
//
//final class LocationRepository: LocationRepositoryProtocol {
//    private let dataSource: LocationDataSourceProtocol
//    
//    init(dataSource remote: LocationDataSourceProtocol) {
//        self.dataSource = remote
//    }
//    
//    func fetchLocations(workspaceId: UUID) async -> RepositoryResult<[Location]> {
//        <#code#>
//    }
//    
//    func fetchLocation(id: UUID) async -> RepositoryResult<Location> {
//        <#code#>
//    }
//    
//    func createLocation(workspaceId: UUID, name: String, color: TagColor) async -> RepositoryResult<Location> {
//        <#code#>
//    }
//    
//    func updateLocation(id: UUID, location: Location) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//    func deleteLocation(id: UUID) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
//        <#code#>
//    }
//    
//    
//}
