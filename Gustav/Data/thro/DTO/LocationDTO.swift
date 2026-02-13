//
//  Location.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 워크스페이스 장소 정보
struct LocationDTO{
    let id: UUID                // 장소 고유 ID
    let workspaceId: UUID       // 워크스페이스 ID
    let indexKey: Int           // 정렬 순서
    let name: String            // 장소 이름
    let color: TagColor         // 장소 색상
}
