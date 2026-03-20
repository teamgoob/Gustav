//
//  WorkspaceCoordinator.swift
//  Gustav
//
//  Created by 박선린 on 3/11/26.
//

import UIKit

final class WorkspaceListCoordinator: BaseCoordinator {
    private let container: WorkspaceListDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    var onSelectWorkspace: ((UUID) -> Void)?
    
    private lazy var viewModel: WorkSpaceListViewModel = {
        container.makeWorkspaceListViewModel()
    }()
    init(
        navigationController: UINavigationController,
        container: WorkspaceListDIContainer
    ) {
        self.container = container
        super.init(navigationController: navigationController)
    }
    
    
    // MARK: - Flow Start
    override func start() {
        super.start()
        // 워크스페이스 목록 화면 연결
        showWorkspaceList()
    }

    // MARK: - Flow Finish
    func finish() {
        // 부모 Coordinator에게 Flow 종료 알림
        onFinish?(self)
    }
    
    
    // MARK: - Deinit Children
    override func removeChild(_ finishedCoordinator: Coordinator) {
        super.removeChild(finishedCoordinator)
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }

}

private extension WorkspaceListCoordinator {
    // Default View
    func showWorkspaceList() {
        let useCase = TestWorkSpaceUsecase()
        let viewModel = WorkSpaceListViewModel(workspaceUsecase: useCase) //혹은 DI 컨테이너 사용
        self.viewModel = viewModel
        let viewController = WorkSpaceListViewController(viewModel: viewModel)
        
        self.viewModel.onNavigation = { [weak self] route in
            switch route {
            case .presentCreateWorkspace:
                self?.presentAddWorkspaceAlert()
            case .pushToAppSetting:
                self?.showAppSettingView()
            case .pushToWorkspaceDetail(let workspace):
                print(workspace.name + "선택됨이 코디네이터에서 실행")
            case .showErrorAlert(let string):
                self?.presentErrorAlert(string: string)
                
            }
        }
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    // WorkspaceDetail
    private func showWorkspaceDetailView(workspace: Workspace) {
        let diContainer = self.container.makeWorkspaceDIContainer(workspaceID: workspace.id)
        let coordinator = WorkspaceCoordinator(navigationController: self.navigationController, container: diContainer, workspaceID: workspace.id)
        coordinator.onFinish = { [weak self] coordinator in
            self?.removeChild(coordinator)
        }
        self.childCoordinators.append(coordinator)
        coordinator.start()
        
    }
    
    // AppSetting
    private func showAppSettingView() {
        let diContainer = self.container.makeAppSettingDIContainer()
        let coordinator = AppSettingCoordinator(navigationController: self.navigationController, container: diContainer)
        coordinator.onFinish = { [weak self] coordinator in
            self?.removeChild(coordinator)
        }
        self.childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    // Created Workspace Alert
    private func presentAddWorkspaceAlert() {
        let alert = UIAlertController(
            title: "Add Workspace",
            message: "Enter a name for your new workspace.",
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "e.g. Personal / Work / Project"
            tf.clearButtonMode = .whileEditing
            tf.autocapitalizationType = .none
            tf.returnKeyType = .done
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)

        let add = UIAlertAction(title: "추가", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            self.viewModel.action(.didTapCreateWorkspace(name: name))
        }

        alert.addAction(cancel)
        alert.addAction(add)

        self.navigationController.present(alert, animated: true)
    }
    // Error Alert
    @MainActor
    private func presentErrorAlert(string: String) {
        let alert = UIAlertController(
            title: "Error",
            message: string,
            preferredStyle: .alert)

        let cancel = UIAlertAction(title: "Cancle", style: .cancel)
        
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true)
    }
}
