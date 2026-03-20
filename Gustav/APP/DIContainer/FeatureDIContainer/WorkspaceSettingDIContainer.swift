//
//  WorkspaceSettingDIContainer.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/20.
//

import Foundation

// MARK: - WorkspaceSettingDIContainer
// WorkspaceSettingCoordinator에서 사용하는 ViewModel들을 생성하는 FeatureDIContainer
final class WorkspaceSettingDIContainer {
    // MARK: - AppDIContainer
    private let appDIContainer: AppDIContainer
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - ViewModel Builder
    // WorkspaceSettingViewModel
    func makeWorkspaceSettingViewModel(for workspace: Workspace) -> WorkspaceSettingViewModel {
        WorkspaceSettingViewModel(workspace: workspace, workspaceUsecase: appDIContainer.workspaceUsecase)
    }
    
    // MARK: - Child DIContainer Builder
    // WorkspaceSettingCoordinator에서 자식 Coordinator를 생성할 때 필요한 FeatureDIContainer를 생성하는 메서드
    // 예시:
    //    func makeCategorySettingsDIContainer() -> CategorySettingsDIContaier {
    //        CategorySettingsDIContainer(appDIContainer: appDIContainer)
    //    }
}
