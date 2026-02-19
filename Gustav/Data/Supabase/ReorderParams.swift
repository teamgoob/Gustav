//
//  ReorderParams.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/20.
//

import Foundation

// MARK: - ReorderParams
// 순서 변경 RPC 호출을 위한 파라미터 정의
nonisolated struct ReorderParams: Encodable {
    let p_user_id: UUID
    let p_order: [UUID]
}
