//
//  ProfileUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

/// MARK: - Profile UseCase Protocol
/// - Presentation(ViewModel)이 호출하는 프로필 관련 유즈케이스
/// - Repository를 감싸고, 필요한 정책(유효성 검증 등)을 적용한다.
protocol ProfileUseCaseProtocol {

    /// 프로필 조회
    /// - 로그인된 사용자 또는 특정 userId의 프로필을 반환
    func fetchProfile(userId: UUID) async -> DomainResult<Profile>

    /// 사용자 이름 변경
    /// - 필요하다면 입력값 검증을 UseCase에서 수행
    func updateUserName(userId: UUID, name: String) async -> DomainResult<Void>

    /// 프로필 upsert
    /// - 로그인 직후 호출될 수 있음
    /// - Repository의 upsertProfile을 감싼다
    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> DomainResult<Void>
}

/// ProfileUseCase의 역할
/// - "프로필 관련 비즈니스 규칙"을 담당하는 계층
/// - Repository는 단순 데이터 접근,
///   UseCase는 입력값 검증 및 정책 판단을 담당
///
/// ✅ 여기서 하는 일
/// - 사용자 입력값 정리(trim)
/// - 이름 길이/빈값 검증
/// - 필요 시 도메인 정책 추가
///
/// ❌ 여기서 하지 않는 일
/// - Supabase 호출
/// - DTO 변환
/// - 네트워크 에러 처리 세부 구현
///   → 모두 Repository 책임

final class ProfileUseCase: ProfileUseCaseProtocol {

    /// 실제 데이터 접근을 담당하는 Repository
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - 프로필 조회

    /// 특정 userId의 프로필을 조회
    /// - 현재는 단순 위임
    /// - 향후 권한 체크/캐시 정책 등이 추가될 수 있는 위치
    func fetchProfile(userId: UUID) async -> DomainResult<Profile> {
        await repository.fetchProfile(userId: userId)
    }

    // MARK: - 사용자 이름 변경

    /// 사용자 이름 변경 요청
    /// - UseCase에서 입력값 검증 수행
    /// - 검증 통과 시 Repository에 위임
    func updateUserName(userId: UUID, name: String) async -> DomainResult<Void> {

        // 1️⃣ 앞뒤 공백 제거 (UI 입력값 정리)
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2️⃣ 빈 문자열 방지
        guard trimmed.isEmpty == false else {
            return .failure(.invalidParameter)
        }

        // 3️⃣ 최대 길이 제한 (정책)
        guard trimmed.count <= 30 else {
            return .failure(.invalidParameter)
        }

        // 4️⃣ 검증 통과 시 Repository에 전달
        return await repository.updateUserName(userId: userId, name: trimmed)
    }

    // MARK: - 프로필 upsert

    /// 로그인 직후 또는 사용자 정보 동기화 시 호출
    /// - Repository의 upsertProfile을 감싸는 역할
    /// - displayName을 정리(trim) 후 전달
    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> DomainResult<Void> {

        // 입력값 정리 (공백 제거)
        let normalizedName = displayName?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return await repository.upsertProfile(
            userId: userId,
            email: email,
            displayName: normalizedName
        )
    }
}
