//
//  WorkspaceCoordinator.swift
//  Gustav
//
//  Created by 박선린 on 3/11/26.
//

 /*
  [song]
  에러 때문에 기존 코드는 주석 처리하였습니다.
  
  아래에 제가 작성한 앱 코디네이터 기반으로 뼈대만 작성해서 커밋했으므로,
  뼈대 기준으로 구현해주시면 감사하겠습니다.
  
  이 주석을 삭제해주시면 됩니다.
  */

import UIKit

final class WorkspaceListCoordinator: BaseCoordinator {
    private let container: WorkspaceListDIContainer
    
    var onFinish: ((Coordinator) -> Void)?
    var onSelectWorkspace: ((UUID) -> Void)?

    init(
        navigationController: UINavigationController,
        container: WorkspaceListDIContainer
    ) {
        self.container = container
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        // 워크스페이스 목록 화면 연결
    }
}

//import UIKit
//
//protocol CoordinatorFinishDelegate: AnyObject {    
//    /// 특정 자식 Coordinator가 종료되었음을 알리는 메서드
//    func coordinatorDidFinish(_ coordinator: CoordinatorProtocol)
//}
//
//protocol CoordinatorProtocol: AnyObject {
//    var navigationController: UINavigationController { get }
//    var childCoordinators: [CoordinatorProtocol] { get set }
//    var finishDelegate: CoordinatorFinishDelegate? { get set }
//    func start()
//    func handle(_ route: WorkSpaceListViewModel.Route)
//}
//
//class WorkspaceCoordinator: CoordinatorProtocol {
//    let navigationController: UINavigationController
//    
//    var childCoordinators: [CoordinatorProtocol] = []
//    
//    weak var finishDelegate: CoordinatorFinishDelegate?
//    var viewModel: WorkSpaceListViewModel?
//    
//    init(navigationController: UINavigationController, finishDelegate: CoordinatorFinishDelegate? = nil) {
//        self.navigationController = navigationController
//        self.finishDelegate = finishDelegate
//    }
//    
//    func start() {
//        let useCase = TestWorkSpaceUsecase()
//        let viewModel = WorkSpaceListViewModel(workspaceUsecase: useCase) //혹은 DI 컨테이너 사용
//        self.viewModel = viewModel
//        let viewController = WorkSpaceListViewController(viewModel: viewModel)
//        
//        viewModel.onNavigation = { [weak self] route in
//            self?.handle(route)
//        }
//        
//        navigationController.pushViewController(viewController, animated: false)
//    }
//    
//    func handle(_ route: WorkSpaceListViewModel.Route) {
//        switch route {
//        case .presentCreateWorkspace:
//            print("zz")
//        case .pushToAppSetting:
//            let settingVC = AppSettingViewController(viewModel: AppSettingViewModel(authUsecase: TestAuthUsecase(), profileUsecase: TestProfileUsecase()))
//            navigationController.pushViewController(settingVC, animated: true)
//        case .pushToWorkspaceDetail(let workspace):
//            print(workspace.name + "선택됨이 코디네이터에서 실행")
//        case .showErrorAlert(let string):
//            presentErrorAlert(string: string)
//            
//        }
//    }
//    
//    
//    
//    
//    @MainActor
//    private func presentErrorAlert(string: String) {
//        let alert = UIAlertController(
//            title: "Error",
//            message: string,
//            preferredStyle: .alert)
//
//        let cancel = UIAlertAction(title: "Cancle", style: .cancel)
//        
//        alert.addAction(cancel)
//        
//        navigationController.present(alert, animated: true)
//    }
//}
