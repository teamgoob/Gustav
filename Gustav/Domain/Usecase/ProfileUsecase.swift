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
}

final class ProfileUsecase: ProfileUsecaseProtocol {
    func fetchProfile() async -> DomainResult<Profile> {
        <#code#>
    }
    
    func updateUserName(_ name: String) async -> DomainResult<Void> {
        <#code#>
    }
}
