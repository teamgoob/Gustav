//
//  Profile.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 프로필 정보
struct Profile {
    let id: UUID        // 사용자 ID
    let name: String?    // 사용자 이름
    let createdAt: Date // 계정 생성일
    let updatedAt: Date // 사용자 이름 업데이트 시 기준
}
