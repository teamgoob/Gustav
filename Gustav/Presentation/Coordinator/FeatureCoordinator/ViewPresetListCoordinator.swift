import UIKit

/// 뷰 프리셋 목록 화면의 흐름을 관리하는 Coordinator
final class ViewPresetListCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    private let container: ViewPresetListDIContainer
    private let selectedWorkspaceId: UUID
    
    var onFinish: ((Coordinator) -> Void)?
    
    // MARK: - Init
    init(
        navigationController: UINavigationController,
        container: ViewPresetListDIContainer,
        selectedWorkspaceId: UUID
    ) {
        self.container = container
        self.selectedWorkspaceId = selectedWorkspaceId
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Flow Start
    override func start() {
        super.start()
        showViewPresetList()
    }
    
    // MARK: - Flow Finish
    func finish() {
        onFinish?(self)
    }
    
    // MARK: - Deinit Children
    override func removeChild(_ finishedCoordinator: Coordinator) {
        super.removeChild(finishedCoordinator)
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }
}

// MARK: - Private
private extension ViewPresetListCoordinator {
    
    func showViewPresetList() {
        let viewModel = container.makeViewPresetListViewModel(workspaceId: selectedWorkspaceId)
        let viewController = ViewPresetListViewController(viewModel: viewModel)
        
        viewController.onRoute = { [weak self] route in
            switch route {
            case .pushToAddPreset:
                self?.showAddPreset()
                
            case .pushToPresetDetail(let id):
                self?.showPresetDetail(presetID: id)
            case .showErrorAlert(let message):
                self?.showErrorAlert(message)
            }
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAddPreset() {
        let presetAddDIContainer = container.makePresetAddDIContainer()

        Task { [weak self] in
            guard let self else { return }

            let viewModel = await presetAddDIContainer.makePresetAddViewModel(workspaceId: selectedWorkspaceId)
            let coordinator = PresetAddCoordinator(
                navigationController: navigationController,
                viewModel: viewModel
            )

            coordinator.onFinish = { [weak self] child in
                self?.removeChild(child)
            }

            childCoordinators.append(coordinator)

            coordinator.start()
        }
    }
    
    func showPresetDetail(presetID: UUID) {
        let presetDetailDIContainer = container.makePresetDetailDIContainer()

        Task { [weak self] in
            guard let self else { return }

            let context = await presetDetailDIContainer.makePresetDetailContext(
                workspaceId: selectedWorkspaceId,
                presetId: presetID
            )

            let coordinator = PresetDetailCoordinator(
                navigationController: navigationController,
                container: presetDetailDIContainer,
                context: context
            )

            coordinator.onFinish = { [weak self] coordinator in
                self?.removeChild(coordinator)
            }

            childCoordinators.append(coordinator)
            coordinator.start()
        }
    }

    func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        navigationController.present(alert, animated: true)
    }


}
