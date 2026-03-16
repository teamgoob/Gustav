//
//  AppCoordinator.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

/*
 상속
 Coordinator protocol
         ↓
 BaseCoordinator
         ↓
 AppCoordinator
 
 */

/*
 •    로그인 여부 판단
 •    로그인 플로우 시작
 •    워크스페이스 목록 플로우 시작
 •    특정 워크스페이스 진입 플로우 시작
 •    로그아웃 / 회원탈퇴 / 워크스페이스 종료 시 루트 흐름 재구성
 */


import UIKit
import Combine

// MARK: - AppCoordinator
final class AppCoordinator: BaseCoordinator {
    // MARK: - Properties
    private let container: AppDIContainer
    private let authStateStore = AuthStateStore.shared
    
    // MARK: - Initializer
    init(
        navigationController: UINavigationController,
        container: AppDIContainer
    ) {
        self.container = container
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Start
    override func start() {
        routeInitialFlow()
    }
}

// MARK: - Private Logic
private extension AppCoordinator {
    // 앱 시작 시 초기 진입 플로우 결정
    func routeInitialFlow() {
        switch AuthStateStore.shared.subject.value {
        case .signedIn:
            showWorkspaceListFlow()
        case .signedOut, .unknown:
            showAuthFlow()
        }
    }
    
    // 로그인 플로우 시작
    func showAuthFlow() {
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        
        let coordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container.makeAuthDIContainer()
        )
        
        coordinator.onFinish = { [weak self, weak coordinator] result in
            guard let self, let coordinator else { return }
            
            self.removeChild(coordinator)
            
            switch result {
            case .signedIn:
                self.showWorkspaceListFlow()
                
            case .cancelled:
                break
            }
        }
        
        addChild(coordinator)
        coordinator.start()
    }
    
    // 워크스페이스 목록 플로우 시작
    func showWorkspaceListFlow() {
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        
        let coordinator = WorkspaceListCoordinator(
            navigationController: navigationController,
            container: container.makeWorkspaceListDIContainer()
        )
        
        coordinator.onFinish = { [weak self, weak coordinator] result in
            guard let self, let coordinator else { return }
            
            self.removeChild(coordinator)
            
            switch result {
            case .signOut:
                self.showAuthFlow()
                
            case .withdrawal:
                self.showAuthFlow()
                
            case .selectWorkspace(let workspaceID):
                self.showWorkspaceFlow(workspaceID: workspaceID)
            }
        }
        
        addChild(coordinator)
        coordinator.start()
    }
    
    // 선택한 워크스페이스 플로우 시작
    func showWorkspaceFlow(workspaceID: UUID) {
        let coordinator = WorkspaceCoordinator(
            navigationController: navigationController,
            container: container.makeWorkspaceDIContainer(workspaceID: workspaceID),
            workspaceID: workspaceID
        )
        
        coordinator.onFinish = { [weak self, weak coordinator] result in
            guard let self, let coordinator else { return }
            
            self.removeChild(coordinator)
            
            switch result {
            case .backToWorkspaceList:
                self.navigationController.popToRootViewController(animated: true)
                
            case .signOut:
                self.showAuthFlow()
                
            case .workspaceDeleted:
                self.navigationController.popToRootViewController(animated: true)
            }
        }
        
        addChild(coordinator)
        coordinator.start()
    }
}
