//
//  TestProfileUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/6.
//

import Foundation

// MARK: - TestProfileUsecase
// UI 테스트용 ProfileUsecase
final class TestProfileUsecase: ProfileUseCaseProtocol {
    func fetchProfile(userId: UUID) async -> DomainResult<Profile> {
        .success(Profile(id: userId, displayName: "Gustav", email: "gustav@example.com", isPrivateEmail: false, createdAt: Date(), updatedAt: Date()))
    }
    
    func updateUserName(userId: UUID, name: String) async -> DomainResult<Void> {
        .success(())
    }
    
    func upsertProfile(userId: UUID, email: String?, displayName: String?) async -> DomainResult<Void> {
        .success(())
    }
}
