//
//  Coordinator+Enum.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

// 하위 코디네이터 finish 이벤트 타입

import Foundation

// MARK: - Auth Flow Result
enum AuthFlowResult {
    case signedIn
    case cancelled
}

// MARK: - Workspace List Flow Result
enum WorkspaceListFlowResult {
    case signOut
    case withdrawal
    case selectWorkspace(UUID)
}

// MARK: - Workspace Flow Result
enum WorkspaceFlowResult {
    case backToWorkspaceList
    case signOut
    case workspaceDeleted
}
