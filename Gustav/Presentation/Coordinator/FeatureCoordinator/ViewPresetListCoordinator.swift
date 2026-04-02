//
//  ViewPresetListCoordinator.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

/// 뷰 프리셋 목록 화면의 흐름을 관리하는 Coordinator
final class ViewPresetListCoordinator: Coordinator {
    
    // MARK: - Properties
    
    /// 화면 전환에 사용할 네비게이션 컨트롤러
    let navigationController: UINavigationController
    
    /// 하위 Coordinator들을 보관하는 배열
    var childCoordinators: [Coordinator] = []
    
    /// ViewPresetList 화면에서 필요한 객체를 생성하는 DIContainer
    private let container: ViewPresetListDIContainer
    
    /// 현재 선택된 워크스페이스 ID
    private let selectedWorkspaceId: UUID
    
    /// 종료 시 상위 Coordinator에 전달하는 콜백
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
    /// 뷰 프리셋 목록 화면을 표시합니다.
    func showViewPresetList() {
        let viewController = container.makeViewPresetListViewController(workspaceId: selectedWorkspaceId)
        
        viewController.onRoute = { [weak self] route in
            self?.handle(route)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    /// ViewModel Route를 해석하여 화면 전환을 처리합니다.
    func handle(_ route: ViewPresetListViewModel.Route) {
        switch route {
        case .pushToAddPreset:
            showAddPreset()
            
        case .pushToPresetDetail(let id):
            showPresetDetail(presetID: id)
        }
    }
    
    /// 프리셋 추가 화면으로 이동합니다.
    func showAddPreset() {
        print("showAddPreset not implemented")
    }
    
    /// 프리셋 상세 화면으로 이동합니다.
    func showPresetDetail(presetID: UUID) {
        print("showPresetDetail not implemented: \(presetID)")
    }
}
