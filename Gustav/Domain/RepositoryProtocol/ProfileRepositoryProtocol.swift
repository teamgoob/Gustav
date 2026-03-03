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
    func fetchProfile(userId: UUID) async -> DomainResult<Profile>
    // 사용자 이름 변경
    func updateUserName(userId: UUID, name: String) async -> DomainResult<Void>

    //upsert = update + insert
    // 프로필이 없으면 만들고, 있으면 최신 정보로 갱신
    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> DomainResult<Void>
}
