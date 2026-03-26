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
        WorkspaceViewModel(workspace: workspace, itemQueryUsecase: appDIContainer.itemQueryUsecase, itemReferenceUsecase: appDIContainer.itemReferenceUsecase)
    }
    
    // MARK: - DIContainer Builder
    func makeWorkspaceSettingDIContainer() -> WorkspaceSettingDIContainer {
        WorkspaceSettingDIContainer(appDIContainer: appDIContainer)
    }
}
