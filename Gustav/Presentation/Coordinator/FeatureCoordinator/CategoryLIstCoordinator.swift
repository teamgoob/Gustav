//
//  CategoryLIstCoordinator.swift
//  Gustav
//
//  Created by 박선린 on 3/23/26.
//
import UIKit

final class CategoryListCoordinator: BaseCoordinator {
    private let container: CategoryListDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    let selectedWorkspaceId: UUID
    
    private lazy var viewModel: CategoryListViewModel = {
        container.makeCategoryListViewModel(selectedWorkspaceId: selectedWorkspaceId)
    }()
    
    init(
        navigationController: UINavigationController,
        container: CategoryListDIContainer,
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
        showCategoryList()
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
    
    // MARK: - Test
    deinit {
        print("CategoryListCoordinator deinit")
    }
}

private extension CategoryListCoordinator {
    // Default View
    func showCategoryList() {
        let viewController = CategoryListViewController(viewModel: self.viewModel)
        
        self.viewModel.onNavigation = { [weak self] route in
            switch route {
            case .dismiss:
                self?.finish()
            case .presentCreateCategory(let category):
                self?.showCategoryDetailView(category: category)
            case .pushToCategoryDetail(let category):
                self?.showCategoryDetailView(category: category)
            case .showErrorAlert(let string):
                self?.presentErrorAlert(string: string)
                
            }
        }
        navigationController.pushViewController(viewController, animated: true)        
    }
    
    // Category Detail
    private func showCategoryDetailView(category: Category) {
        let vm = container.makeCategoryDetailViewModel(category: category)

        vm.onNavigation = { [weak self, weak vm, weak viewModel] route in
            guard let self, let vm, let viewModel else { return }

            switch route {
            case .startChangeName:
                self.presentAddCategoryAlert { newName in
                    vm.action(.changedNameButton(newName))
                }
            case .reFetchCategoryList:
                viewModel.action(.reFetchData)
            case .delete:
                viewModel.action(.reFetchData)
                navigationController.popViewController(animated: true)
            case .showErrorAlert(let string):
                self.presentErrorAlert(string: string)
            }
        }

        let vc = CategoryDetailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    // Change Name (Category Detail)
    @MainActor
    private func presentAddCategoryAlert(onConfirm: @escaping (String) -> Void) {
        let alert = UIAlertController(
            title: "Edit Category Name",
            message: "Enter a new category name.",
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "Category name"
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
