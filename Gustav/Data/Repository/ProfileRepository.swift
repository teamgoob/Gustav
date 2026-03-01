//
//  ProfileRepository.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

/// ProfileRepository의 역할
/// - DataSource(ProfileSupabase)가 가져온 DTO(ProfileDTO)를
///   Domain Entity(Profile)로 바꿔서 반환한다.
/// - DataSource 에러(RepositoryError)를 DomainError로 바꿔서 반환한다.
/// - "도메인 계층"이 Supabase/AnyJSON/DTO를 모르게 만든다.

final class ProfileRepository: ProfileRepositoryProtocol {

    private let dataSource: ProfileDataSourceProtocol

    init(dataSource: ProfileDataSourceProtocol) {
        self.dataSource = dataSource
    }

    // MARK: - 프로필 조회
    func fetchProfile(userId: UUID) async -> DomainResult<Profile> {
        let result = await dataSource.fetchProfile(userId: userId)

        switch result {
        case .success(let dto):
            // DTO -> Domain 변환
            return .success(dto.toDomain())

        case .failure(let e):
            // DataLayer 에러 -> Domain 에러 변환
            return .failure(e.mapToDomainError())
        }
    }

    // MARK: - 사용자 이름 변경
    func updateUserName(userId: UUID, name: String) async -> DomainResult<Void> {
        let result = await dataSource.updateUserName(userId: userId, name: name)

        switch result {
        case .success:
            return .success(())

        case .failure(let e):
            return .failure(e.mapToDomainError())
        }
    }

    // MARK: - upsert (없으면 insert / 있으면 update)
    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> DomainResult<Void> {

        let result = await dataSource.upsertProfile(
            userId: userId,
            email: email,
            displayName: displayName
        )

        switch result {
        case .success:
            return .success(())

        case .failure(let e):
            return .failure(e.mapToDomainError())
        }
    }
}
