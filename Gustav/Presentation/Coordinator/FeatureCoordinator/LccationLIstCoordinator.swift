//
//  CategoryLIstCoordinator.swift
//  Gustav
//
//  Created by 박선린 on 3/23/26.
//
import UIKit

final class LocationListCoordinator: BaseCoordinator {
    private let container: LocationListDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    let selectedWorkspaceId: UUID
    
    private lazy var viewModel: LocationListViewModel = {
        container.makeLocationListViewModel(selectedWorkspaceId: selectedWorkspaceId)
    }()
    
    init(
        navigationController: UINavigationController,
        container: LocationListDIContainer,
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
        showLocationList()
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

    // MARK: - Deinit
    deinit {
        print("LocationListCoordinator deinit")
    }
}

private extension LocationListCoordinator {
    // Default View
    func showLocationList() {
        let viewController = LocationListViewController(viewModel: self.viewModel)
        
        self.viewModel.onNavigation = { [weak self] route in
            switch route {
            case .dismiss:
                self?.finish()
            case .presentCreateLocation(let location):
                self?.showLocationDetailView(location: location)
            case .pushToLocationDetail(let location):
                self?.showLocationDetailView(location: location)
            case .showErrorAlert(let string):
                self?.presentErrorAlert(string: string)
                
            }
        }
        navigationController.pushViewController(viewController, animated: true)        
    }
    
    // Location Detail
    private func showLocationDetailView(location: Location) {
        let vm = container.makeLocationDetailViewModel(location: location)

        vm.onNavigation = { [weak self, weak vm, weak viewModel] route in
            guard let self, let vm, let viewModel else { return }

            switch route {
            case .startChangeName:
                self.presentAddLocationAlert { newName in
                    vm.action(.changedNameButton(newName))
                }
            case .reFetchLocationList:
                viewModel.action(.reFetchData)
            case .delete:
                viewModel.action(.reFetchData)
                navigationController.popViewController(animated: true)
            case .showErrorAlert(let string):
                self.presentErrorAlert(string: string)
            }
        }

        let vc = LocationDetailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    // Change Name (Location Detail)
    @MainActor
    private func presentAddLocationAlert(onConfirm: @escaping (String) -> Void) {
        let alert = UIAlertController(
            title: "Edit Location Name",
            message: "Enter a new Location name.",
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "Location name"
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
