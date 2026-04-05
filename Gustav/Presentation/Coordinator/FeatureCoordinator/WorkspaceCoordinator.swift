//
//  WorkspaceCoordinator 2.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import UIKit

final class WorkspaceCoordinator: Coordinator {
    // MARK: - Properties
    // Navigation Controller
    let navigationController: UINavigationController
    // Child Coordinators
    var childCoordinators: [Coordinator] = []
    // WorkspaceSettingDIContainer
    private let container: WorkspaceDIContainer
    // Workspace Info
    private let workspace: Workspace
    // Root ViewModel - 아이템 삭제 확인 후, 아이템 삭제 메서드 호출을 위해 참조
    private lazy var workspaceViewModel: WorkspaceViewModel = {
        container.makeWorkspaceViewModel(workspace: workspace)
    }()
    
    // MARK: - Closures
    // 부모 Coordinator에게 Flow 종료 알림
    var onFinish: ((Coordinator) -> Void)?
    // 부모 Coordinator에게 워크스페이스 삭제 알림
    var onDeleteWorkspace: (() -> Void)?

    // MARK: - Initializer
    init(navigationController: UINavigationController, container: WorkspaceDIContainer, workspace: Workspace) {
        self.navigationController = navigationController
        self.container = container
        self.workspace = workspace
    }
    
    // MARK: - Flow Start
    func start() {
        // 워크스페이스 설정 목록 표시
        showWorkspaceView()
    }
    
    // MARK: - Flow Finish
    func finish() {
        // 부모 Coordinator에게 Flow 종료 알림
        onFinish?(self)
    }
    
    // MARK: - Deinit Children
    private func removeChild(_ finishedCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }
}

// MARK: - Private Logic
private extension WorkspaceCoordinator {
    // 워크스페이스 화면 (아이템 목록) 표시
    func showWorkspaceView() {
        // VM, VC 선언
        let viewController = WorkspaceViewController(viewModel: workspaceViewModel)
        // VM 클로저 전달
        workspaceViewModel.onNavigation = { [weak self] destination in
            switch destination {
            case .dismiss:
                // Root View Pop 시, 코디네이터 해제
                self?.finish()
            case .showWorkspaceSettings:
                self?.startWorkspaceSettingFlow()
            case .showAddItem:
                self?.showAddItemView()
            case .showEditItem(let id):
                self?.showEditItemView(for: id)
            case .showAlertToNoticeQueryFailure:
                self?.showFailureAlert(for: "Failed to load items.")
            case .showAlertForDeleteItemConfirmation(let cellData):
                self?.showDeleteItemConfirmationAlert(for: cellData)
            case .showAlertForDeleteItemFailure:
                self?.showFailureAlert(for: "Failed to delete item.")
            }
        }
        // 네비게이션 타이틀 크기 설정
        navigationController.navigationBar.prefersLargeTitles = true
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    // 워크스페이스 설정 화면 표시, WorkspaceSettingCoordinator 시작
    func startWorkspaceSettingFlow() {
        // DIContainer, Coordinator 생성
        let diContainer = container.makeWorkspaceSettingDIContainer()
        let coordinator = WorkspaceSettingCoordinator(navigationController: self.navigationController, container: diContainer, workspace: self.workspace)
        // 클로저 할당
        coordinator.onFinish = { [weak self] coordinator in
            self?.removeChild(coordinator)
        }
        // 자식 코디네이터에서 워크스페이스 삭제 시
        coordinator.onDeleteWorkspace = { [weak self] in
            // 현재 화면 Pop
            self?.popCurrentViewController()
            // 부모 코디네이터에 전달
            self?.onDeleteWorkspace?()
        }
        // 자식 코디네이터 배열에 추가
        self.childCoordinators.append(coordinator)
        // 코디네이터 시작
        coordinator.start()
    }
    // 아이템 추가 화면 표시
    func showAddItemView() {
        let diContainer = container.makeItemAddDIContainer()
        let coordinator = ItemAddCoordinator(
            navigationController: navigationController,
            container: diContainer,
            workspaceId: workspace.id
        )
        
        coordinator.onFinish = { [weak self] coordinator in
            self?.removeChild(coordinator)
        }
        
        coordinator.onItemCreated = { [weak self] in
            self?.workspaceViewModel.action(.viewDidAppear)
        }
        
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    // 아이템 수정 화면 표시
    func showEditItemView(for id: UUID) {
        
    }
    // 아이템 삭제 확인 얼럿 창 표시
    func showDeleteItemConfirmationAlert(for cellData: WorkspaceItemCellData) {
        // 얼럿 창 생성
        let alert = UIAlertController(
            title: "Delete Item",
            message: "Are you sure you want to delete item \"\(cellData.name)\"?",
            preferredStyle: .alert
        )
        // 취소 버튼 생성
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        // 삭제 버튼 생성
        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive,
        ) { [weak self] _ in
            self?.workspaceViewModel.action(.itemDeleteConfirmed(cellData.id))
        }
        // 버튼 추가
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        // 얼럿 창 표시
        navigationController.visibleViewController?.present(alert, animated: true)
    }
    // 실패 얼럿 창 표시
    func showFailureAlert(for message: String) {
        // 얼럿 창 생성
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        // 확인 버튼 생성
        let confirmAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        // 버튼 추가
        alert.addAction(confirmAction)
        // 얼럿 창 표시
        navigationController.visibleViewController?.present(alert, animated: true)
    }
    // 현재 화면 Pop
    func popCurrentViewController() {
        navigationController.popViewController(animated: true)
    }
}
