//
//  ReorderParams.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/20.
//

import Foundation

// MARK: - ReorderParams
// WorkspaceReorderParams - 워크스페이스 순서 변경 RPC 호출을 위한 파라미터 정의
nonisolated struct WorkspaceReorderParams: Encodable {
    let p_user_id: UUID
    let p_order: [UUID]
}

// ItemReorderParams - 아이템 순서 변경 RPC 호출을 위한 파라미터 정의
nonisolated struct ItemReorderParams: Encodable {
    let p_workspace_id: UUID
    let p_order: [UUID]
}
