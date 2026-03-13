//
//  WorkspaceCoordinator.swift
//  Gustav
//
//  Created by 박선린 on 3/11/26.
//
import UIKit

protocol CoordinatorFinishDelegate: AnyObject {    
    /// 특정 자식 Coordinator가 종료되었음을 알리는 메서드
    func coordinatorDidFinish(_ coordinator: CoordinatorProtocol)
}

protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [CoordinatorProtocol] { get set }
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    func start()
    func handle(_ route: WorkSpaceListViewModel.Route)
}

class WorkspaceCoordinator: CoordinatorProtocol {
    let navigationController: UINavigationController
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    var viewModel: WorkSpaceListViewModel?
    
    init(navigationController: UINavigationController, finishDelegate: CoordinatorFinishDelegate? = nil) {
        self.navigationController = navigationController
        self.finishDelegate = finishDelegate
    }
    
    func start() {
        let useCase = TestWorkSpaceUsecase()
        let viewModel = WorkSpaceListViewModel(workspaceUsecase: useCase) //혹은 DI 컨테이너 사용
        self.viewModel = viewModel
        let viewController = WorkSpaceListViewController(viewModel: viewModel)
        
        viewModel.onNavigation = { [weak self] route in
            self?.handle(route)
        }
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func handle(_ route: WorkSpaceListViewModel.Route) {
        switch route {
        case .presentCreateWorkspace:
            print("zz")
        case .pushToAppSetting:
            let settingVC = AppSettingViewController(viewModel: AppSettingViewModel(authUsecase: TestAuthUsecase(), profileUsecase: TestProfileUsecase()))
            navigationController.pushViewController(settingVC, animated: true)
        case .pushToWorkspaceDetail(let workspace):
            print(workspace.name + "선택됨이 코디네이터에서 실행")
        case .showErrorAlert(let string):
            presentErrorAlert(string: string)
            
        }
    }
    
    
    
    
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
