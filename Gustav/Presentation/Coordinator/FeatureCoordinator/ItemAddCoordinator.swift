//
//  ItemAddCoordinator.swift
//  Gustav
//
//  Created by kaeun on 3/31/26.
//

import UIKit

/// 아이템 추가 화면의 흐름을 관리하는 Coordinator
/// 역할:
/// - ItemAddDIContainer를 통해 ViewModel 생성
/// - 화면 진입 / 종료 같은 내비게이션 흐름 처리
/// - 저장 완료 시 상위 Coordinator에 이벤트 전달
/// - row 기준 dropdown popup(category / itemState / location)은 ViewController가 직접 처리
final class ItemAddCoordinator: Coordinator {
    
    // MARK: - Properties
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let context: ItemAddContext
    private let container: ItemAddDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    var onItemCreated: (() -> Void)?
    
    // MARK: - Init
    
    init(
        navigationController: UINavigationController,
        container: ItemAddDIContainer,
        context: ItemAddContext
    ) {
        self.navigationController = navigationController
        self.container = container
        self.context = context
    }
    
    // MARK: - Flow Start
    func start() {
        showItemAdd()
    }

    // MARK: - Flow Finish
    func finish() {
        onFinish?(self)
    }

    // MARK: - Deinit Children
    func removeChild(_ finishedCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }
}

private extension ItemAddCoordinator {
    // Default View
    func showItemAdd() {
        let viewModel = self.container.makeItemAddViewModel(context: self.context)
        let viewController = ItemAddViewController(viewModel: viewModel)

        viewController.onRoute = { [weak self] route in
            switch route {
            case .showCategoryPicker,
                 .showItemStatePicker,
                 .showLocationPicker:
                break

            case .dismiss:
                self?.finish()

            case .dismissAfterSave:
                self?.onItemCreated?()
                self?.navigationController.popViewController(animated: true)

            case .showErrorAlert(let message):
                self?.presentErrorAlert(string: message)
            }
        }

        self.navigationController.pushViewController(viewController, animated: true)
    }

    // Error Alert
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
