//
//  AuthUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation


/// MARK: - Auth UseCase Protocol
/// - Presentation(ViewModel/Coordinator)이 호출하는 "인증 유즈케이스" 규격
/// - Repository 호출 결과를 받아서 앱 정책(상태 변경 등)을 적용하는 레이어
///
/// 권장 책임:
/// - AuthSessionRepository/AuthFlowRepository를 조합해서 인증 시퀀스를 완성
/// - Repository 결과를 가공해 Presentation 계층이 사용하기 쉬운 형태로 반환
///
/// UseCase
/// → Repository 호출
/// → 결과 반환
/// → 전역 인증 이벤트(login/logout/deleteAccount)는 NotificationCenter로 처리
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


    init(
        flowRepository: AuthFlowRepositoryProtocol,
        sessionRepository: AuthSessionRepositoryProtocol
    ) {
        self.flowRepository = flowRepository
        self.sessionRepository = sessionRepository
    }

    // MARK: - 앱 시작 시 세션 복구
    /// - 앱 런치 직후 호출된다.
    /// - SDK에 저장된 세션을 확인하고 세션 유무만 반환한다.
    func restoreSession() async -> DomainResult<AuthSession?> {
        await flowRepository.restoreSession()
    }

    // MARK: - Apple 로그인
    /// - Apple 인증 → Supabase 로그인 → Profile upsert까지
    ///   Repository가 조립한 결과를 받는다.
    func authenticateWithApple() async -> DomainResult<AuthOutcome> {
        await sessionRepository.authenticateWithApple()
    }

    // MARK: - Email 회원가입
    /// - 이메일 인증이 필요한 경우에는 emailVerificationRequired를 반환한다.
    /// - session이 포함된 경우에는 authenticated를 반환한다.
    func signUpWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        await sessionRepository.signUpWithEmail(email: email, password: password)
    }

    // MARK: - Email 로그인
    /// - 로그인 성공 시 authenticated를 반환한다.
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        await sessionRepository.signInWithEmail(email: email, password: password)
    }
    
    // MARK: - 비밀번호 재설정 메일 발송
    /// - 이메일 주소로 비밀번호 재설정 메일을 보낸다.
    /// - 인증 상태는 변경하지 않는다.
    func resetPassword(email: String) async -> DomainResult<Void> {
        await sessionRepository.resetPassword(email: email)
    }

    // MARK: - 로그아웃
    /// - 서버 세션 제거 후 전역 로그아웃 Notification을 발행한다.
    func signOut() async -> DomainResult<Void> {
        await flowRepository.signOut()
    }

    // MARK: - 회원탈퇴
    /// - 계정 삭제 성공 시 전역 deleteAccount Notification을 발행한다.
    func withdraw() async -> DomainResult<Void> {
        await sessionRepository.withdraw()
    }

    // MARK: - 현재 로그인 유저 id 조회
    /// - 현재 세션 기반으로 동기적으로 userId를 반환한다.
    func currentUserId() -> UUID? {
        flowRepository.currentUserId()
    }
}
