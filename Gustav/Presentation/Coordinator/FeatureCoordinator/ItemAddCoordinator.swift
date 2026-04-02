//
//  ItemAddCoordinator.swift
//  Gustav
//
//  Created by kaeun on 3/31/26.
//

import UIKit

/// 아이템 추가 화면의 흐름을 관리하는 Coordinator
/// 역할:
/// - ItemAddDIContainer를 통해 ViewController / ViewModel 생성
/// - 화면 진입 / 종료 같은 내비게이션 흐름 처리
/// - 저장 완료 시 상위 Coordinator에 이벤트 전달
/// - row 기준 dropdown popup(category / itemState / location)은 ViewController가 직접 처리
final class ItemAddCoordinator: Coordinator {
    
    // MARK: - Properties
    
    /// 화면 전환에 사용할 네비게이션 컨트롤러
    let navigationController: UINavigationController
    
    /// 하위 Coordinator들을 보관하는 배열
    var childCoordinators: [Coordinator] = []
    
    /// 아이템이 생성될 워크스페이스 ID
    private let workspaceId: UUID
    
    /// Item Add 화면에서 필요한 객체를 생성하는 DIContainer
    private let container: ItemAddDIContainer
    
    /// Coordinator 종료 시 상위 Coordinator가 child 정리를 할 수 있도록 전달하는 콜백
    var onFinish: ((ItemAddCoordinator) -> Void)?
    
    /// 아이템 생성 완료 후 상위 화면 갱신이 필요할 때 사용하는 콜백
    var onItemCreated: (() -> Void)?
    
    // MARK: - Init
    
    init(
        navigationController: UINavigationController,
        container: ItemAddDIContainer,
        workspaceId: UUID
    ) {
        self.navigationController = navigationController
        self.container = container
        self.workspaceId = workspaceId
    }
    
    // MARK: - Public
    
    /// 아이템 추가 화면을 시작합니다.
    /// dropdown 데이터 조회가 async이므로 Task 내부에서 화면을 생성한 뒤 push 합니다.
    func start() {
        Task { [weak self] in
            guard let self else { return }
            
            let viewController = await container.makeItemAddViewController(workspaceId: workspaceId)
            
            viewController.onRoute = { [weak self] route in
                self?.handle(route)
            }
            
            await MainActor.run {
                self.navigationController.pushViewController(viewController, animated: true)
            }
        }
    }
}

// MARK: - Route Handling
private extension ItemAddCoordinator {
    /// ItemAddViewModel의 Route를 해석하여 화면 전환 / 알럿 / 종료를 처리합니다.
    func handle(_ route: ItemAddViewModel.Route) {
        switch route {
        case .showCategoryPicker,
             .showItemStatePicker,
             .showLocationPicker:
            // dropdown popup은 ViewController에서 직접 처리
            break
            
        case .dismiss:
            finishFlow(popViewController: true)
            
        case .dismissAfterSave:
            onItemCreated?()
            finishFlow(popViewController: true)
            
        case .showErrorAlert(let message):
            showAlert(message: message)
        }
    }
}

// MARK: - Presentation Helpers
private extension ItemAddCoordinator {
    /// 기본 알럿을 표시합니다.
    func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    /// 플로우 종료 처리
    /// - popViewController: 현재 Item Add 화면을 네비게이션 스택에서 제거할지 여부
    func finishFlow(popViewController: Bool) {
        if popViewController {
            navigationController.popViewController(animated: true)
        }
        
        onFinish?(self)
    }
}
