//
//  ItemDetailCoordinator.swift
//  Gustav
//
//

import UIKit

final class ItemDetailCoordinator: Coordinator {

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let context: ItemDetailContext
    private let container: ItemAddDIContainer

    var onFinish: ((Coordinator) -> Void)?
    var onItemUpdated: (() -> Void)?

    init(
        navigationController: UINavigationController,
        container: ItemAddDIContainer,
        context: ItemDetailContext
    ) {
        self.navigationController = navigationController
        self.container = container
        self.context = context
    }

    func start() {
        showItemDetail()
    }

    func finish() {
        onFinish?(self)
    }

    func removeChild(_ finishedCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }
}

private extension ItemDetailCoordinator {
    func showItemDetail() {
        let viewModel = container.makeItemDetailViewModel(context: context)
        let viewController = ItemDetailViewController(viewModel: viewModel)

        viewController.onRoute = { [weak self] route in
            switch route {
            case .dismiss:
                self?.finish()

            case .dismissAfterSave:
                self?.onItemUpdated?()
                self?.navigationController.popViewController(animated: true)

            case .showErrorAlert(let message):
                self?.presentErrorAlert(string: message)
            }
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    @MainActor
    private func presentErrorAlert(string: String) {
        let alert = UIAlertController(
            title: "Error",
            message: string,
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancel)

        navigationController.present(alert, animated: true)
    }
}
