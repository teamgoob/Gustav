//
//  ViewPresetListDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//
import Foundation
//import UIKit

final class ViewPresetListDIContainer {
    private let appContainer: AppDIContainer

    init(appContainer: AppDIContainer) {
        self.appContainer = appContainer
    }

    func makeViewPresetListViewModel(workspaceId: UUID) -> ViewPresetListViewModel {
        ViewPresetListViewModel(
            viewPresetUsecase: appContainer.viewPresetUsecase,
            workspaceId: workspaceId
        )
    }


    func makePresetDetailDIContainer() -> PresetDetailDIContainer {
        PresetDetailDIContainer(appDIContainer: appContainer)
    }

    func makePresetAddDIContainer() -> PresetAddDIContainer {
        PresetAddDIContainer(appDIContainer: appContainer)
    }
}
