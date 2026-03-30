//
//  CategoryLIstCoordinator.swift
//  Gustav
//
//  Created by 박선린 on 3/23/26.
//
import UIKit

final class ItemStateListCoordinator: BaseCoordinator {
    private let container: ItemStateListDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    let selectedWorkspaceId: UUID
    
    private lazy var viewModel: ItemStateListViewModel = {
        container.makeItemStateListViewModel(selectedWorkspaceId: selectedWorkspaceId)
    }()
    
    init(
        navigationController: UINavigationController,
        container: ItemStateListDIContainer,
        selectedWorkspaceId: UUID
    ) {
        self.container = container
        self.selectedWorkspaceId = selectedWorkspaceId
        super.init(navigationController: navigationController)
    }
    
    
    // MARK: - Flow Start
    override func start() {
        super.start()
        // 카테고리 목록 화면 연결
        showItemStateList()
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

private extension ItemStateListCoordinator {
    // Default View
    func showItemStateList() {
        let viewController = ItemStateListViewController(viewModel: self.viewModel)
        
        self.viewModel.onNavigation = { [weak self] route in
            switch route {
            case .presentCreateLocation(let itemState):
                self?.showItemStateDetailView(itemState: itemState)
            case .pushToItemStateDetail(let itemState):
                self?.showItemStateDetailView(itemState: itemState)
            case .showErrorAlert(let string):
                self?.presentErrorAlert(string: string)
                
            }
        }
        navigationController.pushViewController(viewController, animated: true)        
    }
    
    // ItemState Detail
    private func showItemStateDetailView(itemState: ItemState) {
        let vm = container.makeItemStateDetailViewModel(itemState: itemState)

        vm.onNavigation = { [weak self, weak vm, weak viewModel] route in
            guard let self, let vm, let viewModel else { return }

            switch route {
            case .startChangeName:
                self.presentAddLocationAlert { newName in
                    vm.action(.changedNameButton(newName))
                }
            case .reFetchItemStateList:
                viewModel.action(.reFetchData)
            case .delete:
                viewModel.action(.reFetchData)
                navigationController.popViewController(animated: true)
            case .showErrorAlert(let string):
                self.presentErrorAlert(string: string)
            }
        }

        let vc = ItemStateDetailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    // Change Name (ItemState Detail)
    @MainActor
    private func presentAddLocationAlert(onConfirm: @escaping (String) -> Void) {
        let alert = UIAlertController(
            title: "Edit ItemState Name",
            message: "Enter a new ItemState name.",
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "ItemState name"
            tf.clearButtonMode = .whileEditing
            tf.returnKeyType = .done
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        let confirm = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            onConfirm(name)
        }

        alert.addAction(cancel)
        alert.addAction(confirm)

        navigationController.present(alert, animated: true)
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
