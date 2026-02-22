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
    
    // 프로필 초기화
    // true: 신규 프로필 생성(첫 가입 취급), false: 기존 프로필
    func bootstrapAfterAppleAuth(
        userId: UUID,
        email: String?,
        fullName: String?
    ) async -> DomainResult<Bool>
}
