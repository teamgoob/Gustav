//
//  ProfileRepository.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//
import Foundation

// DTO → Entity 변환 + 도메인 정책 적용

final class ProfileRepository: ProfileRepositoryProtocol {
    private let dataSource: ProfileDataSourceProtocol

    init(dataSource: ProfileDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    // 사용자 프로필 조회 (Domain Entity 반환)
    func fetchProfile(userId: UUID) async -> DomainResult<Profile> {
        
        // 1) DataSource에 IO(네트워크) 호출을 위임
        let result = await dataSource.fetchProfile(userId: userId)
        switch result {
            
        // 2) 결과를 DomainResult로 변환하면서
            //    - 성공이면 DTO -> Entity로 매핑
            //    - 실패면 RepositoryError -> DomainError로 매핑
        case .success(let row):
            return .success(
                Profile(
                    id: row.id,                         // DTO의 id를 도메인 id로 전달
                    name: row.name,                     // DTO의 name을 도메인 name으로 전달
                    email: row.email,                   // DTO의 email을 도메인 email로 전달
                    isPrivateEmail: row.isPrivateEmail, // DTO의 isPrivateEmail을 도메인 플래그로 전달
                    createdAt: row.createdAt,           // 생성 시각
                    updatedAt: row.updatedAt            // 수정 시각
                )
            )
        case .failure(let e):
            return .failure(e.mapToDomainError())
        }
    }

    // 사용자 이름 변경
    func updateUserName(userId: UUID, name: String) async -> DomainResult<Void> {
        await dataSource.updateUserName(userId: userId, name: name).toDomain()
    }

    // Apple 로그인 직후 프로필 초기화(없으면 생성, 있으면 값 보정)
    // - 반환 Bool 의미:
    //   true  = 신규 프로필 생성됨(첫 가입처럼 취급 가능)
    //   false = 기존 프로필 이미 존재
    func bootstrapAfterAppleAuth(
        userId: UUID,
        email: String?,
        fullName: String?
    ) async -> DomainResult<Bool> {
        await dataSource
            .bootstrapAfterAppleAuth(userId: userId, email: email, fullName: fullName)
            .toDomain()
    }
}

private extension Result where Failure == RepositoryError {
    func toDomain() -> DomainResult<Success> {
        self.mapError { $0.mapToDomainError() }
    }
}
