
import UIKit

/// 뷰 프리셋 목록 화면의 흐름을 관리하는 Coordinator
final class ViewPresetListCoordinator: Coordinator {
    
    // MARK: - Properties
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let container: ViewPresetListDIContainer
    private let selectedWorkspaceId: UUID
    
    var onFinish: ((Coordinator) -> Void)?
    
    // MARK: - Init
    init(
        navigationController: UINavigationController,
        container: ViewPresetListDIContainer,
        selectedWorkspaceId: UUID
    ) {
        self.navigationController = navigationController
        self.container = container
        self.selectedWorkspaceId = selectedWorkspaceId
    }
    
    // MARK: - Public
    func start() {
        showViewPresetList()
    }
    
    func finish() {
        onFinish?(self)
    }
}

// MARK: - Private
private extension ViewPresetListCoordinator {
    
    func showViewPresetList() {
        let viewController = container.makeViewPresetListViewController(workspaceId: selectedWorkspaceId)
        
        viewController.onRoute = { [weak self] route in
            self?.handle(route)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func handle(_ route: ViewPresetListViewModel.Route) {
        switch route {
        case .pushToAddPreset:
            showAddPreset()
            
        case .pushToPresetDetail(let id):
            showPresetDetail(presetID: id)
        }
    }
    
    func showAddPreset() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let coordinator = try await container.makePresetAddCoordinator(
                    navigationController: navigationController,
                    workspaceId: selectedWorkspaceId
                )

                coordinator.onFinish = { [weak self] child in
                    self?.removeChildCoordinator(child)
                }

                childCoordinators.append(coordinator)

                await MainActor.run {
                    coordinator.start()
                }
            } catch {
                print("Failed to create PresetAddCoordinator: \(error)")
            }
        }
    }
    
    func showPresetDetail(presetID: UUID) {
        print("showPresetDetail not implemented: \(presetID)")
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
