//
//  WorkspaceContext.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 종속 데이터 Entity
struct WorkspaceContext {
    let workspace: Workspace     // 워크스페이스 기본 정보
    let categories: [Category]   // 워크스페이스 카테고리 목록
    let locations: [Location]    // 워크스페이스 장소 목록
    let states: [ItemState]      // 워크스페이스 아이템 상태 목록
}
