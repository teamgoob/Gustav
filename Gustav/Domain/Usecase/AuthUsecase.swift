//
//  AuthUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation
import Combine


/// MARK: - Auth UseCase Protocol
/// - Presentation(ViewModel/Coordinator)이 호출하는 "인증 유즈케이스" 규격
/// - Repository 호출 결과를 받아서 앱 정책(상태 변경 등)을 적용하는 레이어
///
/// 권장 책임:
/// - AuthSessionRepository/AuthFlowRepository를 조합해서 인증 시퀀스를 완성
/// - 로그인/로그아웃/세션복구 결과에 따라 AuthStateStore 같은 상태를 갱신(필요하면)
///
///
///UseCase
///→ Repository 호출
///→ 성공 시 AuthState 변경
///→ Coordinator가 자동으로 루트 전환
///
///
///
protocol AuthUseCaseProtocol {

    // 앱 시작 시 자동 로그인 판단 (SDK 세션 복구/refresh 포함)
    func restoreSession() async -> DomainResult<AuthSession?>

    // Apple 로그인 (가입/로그인 통합)
    func authenticateWithApple() async -> DomainResult<AuthOutcome>

    // Email 회원가입
    func signUpWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome>

    // Email 로그인
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome>
    
    // 비밀번호 재설정 메일 발송
    func resetPassword(email: String) async -> DomainResult<Void>

    // 로그아웃
    func signOut() async -> DomainResult<Void>

    // 회원탈퇴
    func withdraw() async -> DomainResult<Void>

    // 현재 로그인 유저 id 조회 (동기)
    func currentUserId() -> UUID?
}

final class AuthUseCase: AuthUseCaseProtocol {

    /// 세션 복구 / 로그아웃 / 현재 userId 조회를 담당하는 Repository
    /// - “이미 존재하는 세션 기반 흐름” 담당
    private let flowRepository: AuthFlowRepositoryProtocol

    /// 로그인 / 회원가입 / 탈퇴 같은 “사용자 액션 기반 인증 흐름” 담당 Repository
    private let sessionRepository: AuthSessionRepositoryProtocol

    /// 전역 인증 상태 저장소
    /// - RootCoordinator가 이 값을 구독하고 루트 화면을 전환한다.
    /// - UseCase가 상태 변경을 트리거한다.
    private let authState: AuthStateStore

    init(
        flowRepository: AuthFlowRepositoryProtocol,
        sessionRepository: AuthSessionRepositoryProtocol,
        authState: AuthStateStore = .shared
    ) {
        self.flowRepository = flowRepository
        self.sessionRepository = sessionRepository
        self.authState = authState
    }

    // MARK: - 앱 시작 시 세션 복구
    /// - 앱 런치 직후 호출된다.
    /// - SDK에 저장된 세션을 확인하고
    ///   • 존재하면 signedIn 발행
    ///   • 없으면 signedOut 발행
    ///
    /// UseCase는 “Repository 결과 + 상태 변경”까지 책임진다.
    func restoreSession() async -> DomainResult<AuthSession?> {
        let result = await flowRepository.restoreSession()

        switch result {
        case .success(let session):

            if let session {
                // 세션 존재 → 로그인 상태로 전환
                authState.subject.send(.signedIn(userId: session.userId))
            } else {
                // 세션 없음 → 비로그인 상태
                authState.subject.send(.signedOut)
            }

            return .success(session)

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Apple 로그인
    /// - Apple 인증 → Supabase 로그인 → Profile upsert까지
    ///   Repository가 조립한 결과를 받는다.
    /// - 성공 시 전역 상태를 signedIn으로 변경한다.
    func authenticateWithApple() async -> DomainResult<AuthOutcome> {
        let result = await sessionRepository.authenticateWithApple()

        switch result {
        case .success(let outcome):

            // 로그인 성공한 경우에만 상태 변경
            if case let .authenticated(session, _) = outcome {
                authState.subject.send(.signedIn(userId: session.userId))
            }

            return .success(outcome)

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Email 회원가입
    /// - 이메일 인증이 필요한 경우에는 signedIn으로 바꾸지 않는다.
    /// - session이 포함된 경우에만 로그인 상태로 전환한다.
    func signUpWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        let result = await sessionRepository.signUpWithEmail(email: email, password: password)

        switch result {
        case .success(let outcome):

            if case let .authenticated(session, _) = outcome {
                authState.subject.send(.signedIn(userId: session.userId))
            }

            return .success(outcome)

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Email 로그인
    /// - 로그인 성공 시 signedIn 발행
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        let result = await sessionRepository.signInWithEmail(email: email, password: password)

        switch result {
        case .success(let outcome):

            if case let .authenticated(session, _) = outcome {
                authState.subject.send(.signedIn(userId: session.userId))
            }

            return .success(outcome)

        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - 비밀번호 재설정 메일 발송
    /// - 이메일 주소로 비밀번호 재설정 메일을 보낸다.
    /// - 인증 상태는 변경하지 않는다.
    func resetPassword(email: String) async -> DomainResult<Void> {
        let result = await sessionRepository.resetPassword(email: email)

        switch result {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - 로그아웃
    /// - 서버 세션 제거 후 signedOut 발행
    /// - RootCoordinator가 자동으로 로그인 화면으로 전환
    func signOut() async -> DomainResult<Void> {
        let result = await flowRepository.signOut()

        switch result {
        case .success:
            authState.subject.send(.signedOut)
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - 회원탈퇴
    /// - 계정 삭제 성공 시 로그인 상태를 해제한다.
    func withdraw() async -> DomainResult<Void> {
        let result = await sessionRepository.withdraw()

        switch result {
        case .success:
            authState.subject.send(.signedOut)
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - 현재 로그인 유저 id 조회
    /// - 전역 상태를 통해 동기적으로 userId를 반환한다.
    func currentUserId() -> UUID? {
        flowRepository.currentUserId()
    }
}
