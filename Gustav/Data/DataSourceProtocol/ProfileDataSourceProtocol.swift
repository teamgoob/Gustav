//
//  ProfileDataSourceProtocol.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

protocol ProfileDataSourceProtocol {
    func fetchProfile(userId: UUID) async -> RepositoryResult<ProfileRecord>
    func updateUserName(userId: UUID, name: String) async -> RepositoryResult<Void>

    // true: 신규 생성, false: 기존
    func bootstrapAfterAppleAuth(
        userId: UUID,
        email: String?,
        fullName: String?
    ) async -> RepositoryResult<Bool>
}
