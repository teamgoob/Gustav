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
/// 2) 세션 존재 여부를 반환하여 AppCoordinator가 초기 Flow를 결정할 수 있게 한다.
/// 3) 로그아웃 시 서버 세션을 제거하고 전역 로그아웃 Notification을 발행한다.
/// 4) 현재 구현 기준 currentUserId()는 사용하지 않는다.
///
/// 전역 인증 이벤트(login / logout / deleteAccount)는
/// NotificationCenter를 통해 AppCoordinator가 처리한다.

final class AuthFlowRepository: AuthFlowRepositoryProtocol {

    /// Supabase 세션 관련 호출을 담당하는 DataSource
    private let authDataSource: AuthDataSourceProtocol

    init(authDataSource: AuthDataSourceProtocol) {
        self.authDataSource = authDataSource
    }

    /// 앱 시작 시 호출되는 세션 복구 함수
    /// - SDK에 저장된 세션을 확인
    /// - 세션이 있으면 AuthSession 반환
    /// - 세션이 없으면 nil 반환
    func restoreSession() async -> DomainResult<AuthSession?> {
        let result = await authDataSource.validSession()

        switch result {
        case .success(let dto):

            return .success(dto?.toDomain())
            
        case .failure(let e):

            // 세션 만료/없음은 비로그인 상태로 통일
            if e == .sessionNotFound || e == .unauthorized {
                return .success(nil)
            }

            return .failure(e.mapToDomainError())
        }
    }

    /// 로그아웃 처리
    /// - 서버 세션 제거
    /// - 전역 로그아웃 Notification 발행
    func signOut() async -> DomainResult<Void> {
        let result = await authDataSource.signOut()

        switch result {
        case .success:
            return .success(())

        case .failure(let e):
            return .failure(e.mapToDomainError())
        }
    }

    /// 현재 로그인된 유저 ID를 동기적으로 반환
    func currentUserId() -> UUID? {
        authDataSource.currentUserId()
    }
}
