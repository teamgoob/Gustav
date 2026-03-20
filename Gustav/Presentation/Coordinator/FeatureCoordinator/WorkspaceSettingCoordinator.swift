//
//  WorkspaceSettingCoordinator.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/20.
//

import UIKit

// MARK: - WorkspaceSettingCoordinator
// 워크스페이스 설정 코디네이터, Root View: WorkspaceSettingView
final class WorkspaceSettingCoordinator: Coordinator {
    // MARK: - Properties
    // Navigation Controller
    let navigationController: UINavigationController
    // Child Coordinators
    var childCoordinators: [Coordinator] = []
    // WorkspaceSettingDIContainer
    private let container: WorkspaceSettingDIContainer
    // Workspace Info
    private let workspace: Workspace
    // Root ViewModel - 워크스페이스 삭제 얼럿 창에서 확인 선택 시, ViewModel 메서드 호출을 위해 참조
    private lazy var workspaceSettingViewModel: WorkspaceSettingViewModel = {
        container.makeWorkspaceSettingViewModel(for: workspace)
    }()
    
    // MARK: - Closures
    // 부모 Coordinator에게 Flow 종료 알림
    var onFinish: ((Coordinator) -> Void)?
    // 부모 Coordinator에게 워크스페이스 삭제 알림
    var onDeleteWorkspace: (() -> Void)?
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, container: WorkspaceSettingDIContainer, workspace: Workspace) {
        self.navigationController = navigationController
        self.container = container
        self.workspace = workspace
    }
    
    // MARK: - Flow Start
    func start() {
        // 워크스페이스 설정 목록 표시
        showWorkspaceSettingList()
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
private extension WorkspaceSettingCoordinator {
    // 설정 목록 화면 표시
    func showWorkspaceSettingList() {
        // VM, VC 선언
        let viewController = WorkspaceSettingViewController(viewModel: workspaceSettingViewModel)
        // VM 클로저 전달
        workspaceSettingViewModel.onNavigation = { [weak self] destination in
            switch destination {
            case .dismiss:
                // Root View Pop 시, 코디네이터 해제
                self?.finish()
            case .pushTo(next: let next):
                switch next {
                case .categorySettings:
                    self?.showCategorySettings()
                case .setCategoriesInBulk:
                    self?.showCategoryBulkSetting()
                case .locationSettings:
                    self?.showLocationSettings()
                case .setLocationsInBulk:
                    self?.showLocationBulkSetting()
                case .itemStateSettings:
                    self?.showItemStateSettings()
                case .setItemStatesInBulk:
                    self?.showItemStateBulkSetting()
                case .viewPresetSettings:
                    self?.showViewPresetSettings()
                case .deleteWorkspace:
                    break
                }
            case .showAlertForDeletingWorkspaceConfirmation:
                self?.showAlertForDeletingWorkspace()
            case .finishedToDeleteWorkspace(success: let result):
                switch result {
                case true:
                    // 현재 화면 Pop
                    self?.popCurrentViewController()
                    // 부모 Coordinator에게 워크스페이스 삭제 알림
                    self?.onDeleteWorkspace?()
                case false:
                    // 워크스페이스 삭제 실패 얼럿 창 표시
                    self?.showFailureAlert(for: "Failed to delete the workspace. Please try again.")
                }
            }
        }
        // 네비게이션 타이틀 크기 설정
        navigationController.navigationBar.prefersLargeTitles = true
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // 카테고리 설정 화면 표시
    func showCategorySettings() {}
    // 카테고리 일괄 설정 화면 표시
    func showCategoryBulkSetting() {}
    // 장소 설정 화면 표시
    func showLocationSettings() {}
    // 장소 일괄 설정 화면 표시
    func showLocationBulkSetting() {}
    // 아이템 상태 설정 화면 표시
    func showItemStateSettings() {}
    // 아이템 상태 일괄 설정 화면 표시
    func showItemStateBulkSetting() {}
    // 뷰 프리셋 설정 화면 표시
    func showViewPresetSettings() {}
    // 워크스페이스 삭제 확인 얼럿 창 표시
    func showAlertForDeletingWorkspace() {
        // 얼럿 창 생성
        let alert = UIAlertController(
            title: "Delete workspace",
            message: "Are you sure you want to delete workspace \(workspace.name)?",
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
            style: .destructive
        ) { [weak self] _ in
            self?.workspaceSettingViewModel.action(.confirmDeleteWorkspace)
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
