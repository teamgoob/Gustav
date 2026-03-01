//
//  AuthFlowRepository.swift
//  Gustav
//
//  Created by kaeun on 3/2/26.
//
import Foundation
import Combine

/// AuthFlowRepository의 역할
/// - "앱 시작 이후의 인증 상태 흐름"을 관리하는 Repository
/// - 세션 복구, 로그아웃과 같이
///   “이미 존재하는 세션을 기준으로 상태를 결정”하는 책임을 가진다.
///
/// 주요 책임:
/// 1) 앱 시작 시 restoreSession()으로 세션을 복구한다.
/// 2) 세션 존재 여부에 따라 AuthState를 .signedIn / .signedOut으로 발행한다.
/// 3) 로그아웃 시 서버 세션을 제거하고 AuthState를 .signedOut으로 발행한다.
/// 4) 현재 로그인된 userId를 동기적으로 제공한다.
///
/// 이 Repository는 네트워크 호출(DataSource) +
/// 전역 인증 상태(AuthStateStore) 연결 역할을 수행한다.

final class AuthFlowRepository: AuthFlowRepositoryProtocol {

    /// Supabase 세션 관련 호출을 담당하는 DataSource
    private let authDataSource: AuthDataSourceProtocol

    /// 전역 인증 상태를 관리하는 Store
    /// - RootCoordinator가 이 값을 구독하여 루트 화면을 전환한다.
    private let authState: AuthStateStore

    init(
        authDataSource: AuthDataSourceProtocol,
        authState: AuthStateStore = .shared
    ) {
        self.authDataSource = authDataSource
        self.authState = authState
    }

    /// 앱 시작 시 호출되는 세션 복구 함수
    /// - SDK에 저장된 세션을 확인
    /// - 있으면 signedIn 발행
    /// - 없으면 signedOut 발행
    func restoreSession() async -> DomainResult<AuthSession?> {
        let result = await authDataSource.validSession()

        switch result {
        case .success(let dto):

            if let dto {
                // 세션 존재 → 로그인 상태로 전환
                authState.subject.send(.signedIn(userId: dto.userId))
                return .success(dto.toDomain())
            } else {
                // 세션 없음 → 비로그인 상태
                authState.subject.send(.signedOut)
                return .success(nil)
            }

        case .failure(let e):

            // 세션 만료/없음은 비로그인 상태로 통일
            if e == .sessionNotFound || e == .unauthorized {
                authState.subject.send(.signedOut)
                return .success(nil)
            }

            return .failure(e.mapToDomainError())
        }
    }

    /// 로그아웃 처리
    /// - 서버 세션 제거
    /// - 전역 상태를 signedOut으로 변경
    func signOut() async -> DomainResult<Void> {
        let result = await authDataSource.signOut()

        switch result {
        case .success:
            authState.subject.send(.signedOut)
            return .success(())

        case .failure(let e):
            return .failure(e.mapToDomainError())
        }
    }

    /// 현재 로그인된 유저 ID를 동기적으로 반환
    /// - AuthStateStore의 현재 값에서 추출
    func currentUserId() -> UUID? {
        if case let .signedIn(userId) = authState.subject.value {
            return userId
        }
        return nil
    }
}
