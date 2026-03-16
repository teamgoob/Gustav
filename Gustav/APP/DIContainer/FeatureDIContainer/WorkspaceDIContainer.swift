//

//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import Foundation


final class WorkspaceDIContainer {
    private let appContainer: AppDIContainer
    private let workspaceID: UUID

    init(appContainer: AppDIContainer, workspaceID: UUID) {
        self.appContainer = appContainer
        self.workspaceID = workspaceID
    }
}
