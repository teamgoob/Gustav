//
//  ProfileDataSourceProtocol.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

protocol ProfileDataSourceProtocol {
    func fetchProfile(userId: UUID) async -> RepositoryResult<ProfileDTO>
    func updateUserName(userId: UUID, name: String) async -> RepositoryResult<Void>

    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> RepositoryResult<Void>
}
