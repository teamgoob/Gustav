//

//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import Foundation

final class WorkspaceListDIContainer {
    private let appContainer: AppDIContainer

    init(appContainer: AppDIContainer) {
        self.appContainer = appContainer
    }
    
    // MARK: - ViewModel Builder
    func makeWorkspaceListViewModel() -> WorkSpaceListViewModel {
        WorkSpaceListViewModel(workspaceUsecase: appContainer.workspaceUsecase, authenticationUsecase: appContainer.authUsecase, profileUsecase: appContainer.profileUsecase)
    }
    
    // MARK: - DIContainer Builder
    func makeAppSettingDIContainer() -> AppSettingDIContainer {
        appContainer.makeAppSettingDIContainer()
    }
    
    func makeWorkspaceDIContainer(workspaceID: UUID) -> WorkspaceDIContainer {
        appContainer.makeWorkspaceDIContainer(workspaceID: workspaceID)
    }
    
    
    
        
}
