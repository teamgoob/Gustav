//
//  WorkspaceCoordinator 2.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

/*
 [song]
 에러 때문에 기존 코드는 주석 처리하였습니다.
 
 아래에 제가 작성한 앱 코디네이터 기반으로 뼈대만 작성해서 커밋했으므로,
 뼈대 기준으로 구현해주시면 감사하겠습니다.
 
 이 주석을 삭제해주시면 됩니다.
 */

import UIKit

final class WorkspaceCoordinator: BaseCoordinator {
    private let container: WorkspaceDIContainer
    private let workspaceID: UUID
    
    var onFinish: ((Coordinator) -> Void)?
    var onBackToWorkspaceList: (() -> Void)?
    var onWorkspaceDeleted: (() -> Void)?

    init(
        navigationController: UINavigationController,
        container: WorkspaceDIContainer,
        workspaceID: UUID
    ) {
        self.container = container
        self.workspaceID = workspaceID
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        // 워크스페이스 상세 화면 연결
    }
}
