//
//  CategoryListDIContainer.swift
//  Gustav
//
//  Created by 박선린 on 3/23/26.
//
import Foundation

final class LocationListDIContainer {
    private let appContainer: AppDIContainer

    init(appContainer: AppDIContainer) {
        self.appContainer = appContainer
    }
    
    // MARK: - ViewModel Builder
    func makeLocationListViewModel(selectedWorkspaceId: UUID) -> LocationListViewModel {
        LocationListViewModel(locationUsecase: appContainer.locationUsecase, selectedWorkspaceId: selectedWorkspaceId)
    }
    
    func makeLocationDetailViewModel(location: Location) -> LocationDetailViewModel {
        LocationDetailViewModel(
            location: location,
            locationUsecase: appContainer.locationUsecase,
            itemQueryUsecase: appContainer.itemQueryUsecase
        )
    }
}
