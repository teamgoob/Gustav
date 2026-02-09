//
//  ProfileRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 프로필 Repository Protocol
protocol ProfileRepositoryProtocol {
    // 프로필 조회
    func fetchProfile(userId: UUID) -> RepositoryResult<Profile>

    // 사용자 이름 변경
    func updateUserName(userId: UUID, name: String) -> RepositoryResult<Void>
}
