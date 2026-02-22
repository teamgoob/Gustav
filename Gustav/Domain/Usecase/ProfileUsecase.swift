//
//  ProfileUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 프로필 관리 Usecase
protocol ProfileUsecaseProtocol {
    // 현재 사용자 프로필 조회
    func fetchProfile() async -> DomainResult<Profile>

    // 사용자 이름 변경
    func updateUserName(_ name: String) async -> DomainResult<Void>
    
    // true면 신규 가입처럼 취급 가능
    func bootstrapAfterAppleAuth(email: String?, fullName: String?) async -> DomainResult<Bool>
}

final class ProfileUsecase: ProfileUsecaseProtocol {
    private let authRepo: AuthRepositoryProtocol
    private let profileRepo: ProfileRepositoryProtocol
    
    init(
        authRepo: AuthRepositoryProtocol,
        profileRepo: ProfileRepositoryProtocol
    ) {
        self.authRepo = authRepo
        self.profileRepo = profileRepo
    }
    
    func fetchProfile() async -> DomainResult<Profile> {
        // 1) 현재 유저 id
        let userIdResult = await authRepo.currentUserId()
        switch userIdResult {
        case .failure(let e):
            return .failure(e)
        case .success(let userId):
            // 2) 프로필 조회
            return await profileRepo.fetchProfile(userId: userId)
        }
    }
    
    func updateUserName(_ name: String) async -> DomainResult<Void> {
        // 앞/뒤 공백 다듬기
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        // 이름 길이 검증
        guard (1...20).contains(trimmed.count) else {
            return .failure(.invalidOperation)
        }
        // UserID 요청
        let userIdResult = await authRepo.currentUserId()
        switch userIdResult {
        case .failure(let e):
            // 도메인 에러 리턴
            return .failure(e)
        // 성공
        case .success(let userId):
            return await profileRepo.updateUserName(userId: userId, name: trimmed)
        }
    }
    
    // 현재 로그인된 유저의 ID를 가져와서, 그 유저의 프로필을 생성하거나 확인한다
    func bootstrapAfterAppleAuth(email: String?, fullName: String?) async -> DomainResult<Bool> {
        let userIdResult = await authRepo.currentUserId()
        switch userIdResult {
        case .failure(let e):
            return .failure(e)
        case .success(let userId):
            return await profileRepo.bootstrapAfterAppleAuth(
                userId: userId,
                email: email,
                fullName: fullName
            )
        }
    }
}
