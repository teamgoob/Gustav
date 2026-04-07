//

//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import Foundation

// MARK: - WorkspaceDIContainer
// WorkspaceCoordinator에서 사용하는 ViewModel들을 생성하는 FeatureDIContainer
final class WorkspaceDIContainer {
    // MARK: - AppDIContainer
    private let appDIContainer: AppDIContainer
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - ViewModel Builder
    func makeWorkspaceViewModel(workspace: Workspace) -> WorkspaceViewModel {
        WorkspaceViewModel(workspace: workspace, itemUsecase: appDIContainer.itemUsecase, itemQueryUsecase: appDIContainer.itemQueryUsecase, itemReferenceUsecase: appDIContainer.itemReferenceUsecase, workspaceContextUsecase: appDIContainer.workspaceContextUsecase, viewPresetUsecase: appDIContainer.viewPresetUsecase)
    }
    
    // MARK: - DIContainer Builder
    func makeWorkspaceSettingDIContainer() -> WorkspaceSettingDIContainer {
        WorkspaceSettingDIContainer(appDIContainer: appDIContainer)
    }
    
    func makeItemAddDIContainer() -> ItemAddDIContainer {
        ItemAddDIContainer(appDIContainer: appDIContainer)
    }
}
