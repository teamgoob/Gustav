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
// Root Coordinator
// 앱 전체 Flow를 관리하는 Coordinator

import UIKit

// MARK: - AppCoordinator
final class AppCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    private let container: AppDIContainer
    private var didResolveInitialRouteExternally = false
    
    // MARK: - Initializer
    init(
        navigationController: UINavigationController,
        container: AppDIContainer
    ) {
        self.container = container
        super.init(navigationController: navigationController)
        observeAuthEvents()
    }
    
    // MARK: - Start
    override func start() {
        routeInitialFlow()
    }
    
}

// MARK: - Private Logic
private extension AppCoordinator {
    
    // 앱 시작 시 인증 상태를 확인하여 초기 Flow를 결정
    func routeInitialFlow() {
        Task { @MainActor in
            let result = await container.authUsecase.restoreSession()
            guard !didResolveInitialRouteExternally else { return }

            switch result {
            case .success(let session):
                if session != nil {
                    showWorkspaceListFlow()
                } else {
                    showAuthFlow()
                }

            case .failure:
                showAuthFlow()
            }
        }
    }
    
    // 인증 관련 Notification 구독
    func observeAuthEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogin),
            name: .login,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePasswordRecovery),
            name: .passwordRecovery,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .logout,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeleteAccount),
            name: .deleteAccount,
            object: nil
        )
    }
    
    // 로그인 이벤트 처리
    @objc
    func handleLogin() {
        didResolveInitialRouteExternally = true
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        showWorkspaceListFlow()
    }

    // recovery 링크로 진입한 경우 reset 화면부터 시작
    @objc
    func handlePasswordRecovery() {
        didResolveInitialRouteExternally = true
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)

        let coordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container.makeAuthDIContainer()
        )

        coordinator.onFinish = { [weak self] child in
            self?.removeChild(child)
        }

        addChild(coordinator)
        coordinator.start()
        coordinator.showResetPassword()
    }
    
    // 로그아웃 이벤트 처리
    @objc
    func handleLogout() {
        didResolveInitialRouteExternally = true
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        showAuthFlow()
    }
    
    // 회원 탈퇴 이벤트 처리
    @objc
    func handleDeleteAccount() {
        didResolveInitialRouteExternally = true
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        showAuthFlow()
    }
    
    // Auth Flow 시작
    // 기존 ChildCoordinator와 Navigation Stack을 정리한 후
    // AuthCoordinator를 루트로 설정
    func showAuthFlow() {
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        
        let coordinator = AuthCoordinator(
            navigationController: navigationController,
            container: container.makeAuthDIContainer()
        )
        
        coordinator.onFinish = { [weak self] child in
            self?.removeChild(child)
        }

        
        addChild(coordinator)
        coordinator.start()
    }
    
    // WorkspaceList Flow 시작
    // 로그인 성공 또는 Workspace Flow 종료 후 호출
    func showWorkspaceListFlow() {
        // 기존 루트 플로우 정리
        removeAllChildren()
        navigationController.setViewControllers([], animated: false)
        
        // 새 child coordinator 생성 + 등록
        let coordinator = WorkspaceListCoordinator(
            navigationController: navigationController,
            container: container.makeWorkspaceListDIContainer()
        )
        
        // 자식 코디네이터 종료 처리 (전역 이벤트)
        coordinator.onFinish = { [weak self] child in
            self?.removeChild(child)
        }
        
        addChild(coordinator)
        coordinator.start()
    }
}
