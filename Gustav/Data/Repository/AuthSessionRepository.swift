//
//  AuthSessionRepository.swift
//  Gustav
//
//  Created by kaeun on 3/2/26.
//

import Foundation
import AuthenticationServices

/// AuthSessionRepository의 역할
/// - “로그인 관련 흐름을 조립”하는 곳입니다.
/// - 즉, 여러 컴포넌트(Apple 로그인, Supabase 로그인, Profile upsert)를
///   순서대로 묶어서 ‘하나의 로그인’으로 만들어줍니다.
///
/// ✅ 여기서 하는 일(= 흐름 조립)
/// 1) AppleAuthProvider로 Apple 로그인 UI를 띄우고 idToken/nonce를 받는다
/// 2) AuthDataSource(Supabase)로 실제 로그인 요청을 보내서 세션(AuthDTO)을 받는다
/// 3) 로그인 직후 ProfileDataSource로 profiles 테이블 upsert를 수행한다(프로필 보장)
/// 4) 최종적으로 Domain 결과(AuthOutcome)를 만들어서 위(UseCase/VM)로 올린다
///
/// ❌ 여기서 안 하는 일(= 책임 밖)
/// - Supabase SDK 직접 호출(네트워크 호출) : AuthSupabase / ProfileSupabase가 한다
/// - Apple 로그인 delegate 처리 : AppleAuthProvider가 한다
/// - 화면 전환 / UI 업데이트 : ViewModel / Coordinator가 한다
final class AuthSessionRepository: AuthSessionRepositoryProtocol {

    /// Apple 로그인 UI를 띄우고 결과(idToken/nonce/email/fullName)를 받아오는 역할
    /// - 구현체는 AppleAuthProvider
    private let appleAuthProvider: AppleAuthProviding

    /// Supabase Auth를 호출해서 실제 “세션 발급”을 받는 역할
    /// - 구현체는 AuthSupabase
    private let authDataSource: AuthDataSourceProtocol

    /// profiles 테이블을 읽고/쓰는 역할(프로필 upsert 포함)
    /// - 구현체는 ProfileSupabase
    private let profileDataSource: ProfileDataSourceProtocol

    /// Apple 로그인 UI는 “어느 window 위에 띄울지”가 반드시 필요합니다.
    /// - Repository가 UIKit을 직접 다루지 않게 하려고
    /// - window(anchor)를 “함수로 주입받는 방식”을 씁니다.
    private let presentationAnchorProvider: () -> ASPresentationAnchor

    init(
        appleAuthProvider: AppleAuthProviding,
        authDataSource: AuthDataSourceProtocol,
        profileDataSource: ProfileDataSourceProtocol,
        presentationAnchorProvider: @escaping () -> ASPresentationAnchor
    ) {
        self.appleAuthProvider = appleAuthProvider
        self.authDataSource = authDataSource
        self.profileDataSource = profileDataSource
        self.presentationAnchorProvider = presentationAnchorProvider
    }

    // MARK: - Apple 로그인 (가입/로그인 통합)
    /// Apple 로그인은 “가입/로그인”을 앱이 구분하지 않습니다.
    /// - Apple 인증 성공 → Supabase에 idToken/nonce 전달 → Supabase가
    ///   • 계정이 있으면 로그인
    ///   • 계정이 없으면 생성(가입)
    /// 을 해주는 구조가 일반적입니다.
    func authenticateWithApple() async -> DomainResult<AuthOutcome> {

        // 1) Apple 로그인 UI를 띄우고 idToken/nonce 등을 받습니다.
        // - presentationAnchorProvider()가 “UI를 띄울 창(window)”을 제공합니다.
        let tokenResult = await appleAuthProvider.signIn(
            presentationAnchor: presentationAnchorProvider()
        )

        // 2) Apple 로그인 자체가 실패하면 여기서 끝냅니다.
        switch tokenResult {
        case .failure(let appleError):
            // AppleAuthError를 RepositoryError → DomainError로 변환해서 올립니다.
            return .failure(
                appleError.mapToRepositoryError().mapToDomainError()
            )

        case .success(let token):

            // 3) Apple에서 받은 idToken + nonce를 Supabase로 보내서 세션을 발급받습니다.
            let authResult = await authDataSource.signInWithApple(
                idToken: token.idToken,
                nonce: token.nonce
            )

            switch authResult {
            case .failure(let e):
                // Supabase 로그인 실패
                return .failure(e.mapToDomainError())

            case .success(let authDTO):

                // 4) “로그인 성공 직후” profile upsert
                // - 이유: profiles 테이블 row가 없으면 이후 앱에서 profile 조회가 깨질 수 있음
                // - Apple은 email/fullName을 “첫 동의 때만” 주는 경우가 많아서
                //   이 타이밍에 DB에 저장해두는 게 중요함
                let upsert = await profileDataSource.upsertProfile(
                    userId: authDTO.userId,
                    email: token.email,
                    displayName: token.fullName
                )

                // upsert 실패를 로그인 실패로 볼지(정책) 결정해야 함
                // 여기서는 “로그인 실패”로 처리함
                if case .failure(let e) = upsert {
                    return .failure(e.mapToDomainError())
                }

                // 5) 최종적으로 Domain 결과(AuthOutcome) 반환
                return .success(
                    .authenticated(
                        session: authDTO.toDomain(),
                        isNewUser: false
                    )
                )
            }
        }
    }

    // MARK: - Email 회원가입
    /// 이메일 회원가입은 “이메일 인증이 필요한 경우” session이 nil일 수 있습니다.
    /// - session이 nil이면 아직 로그인 상태가 아님(메일 인증 필요)
    func signUpWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        let result = await authDataSource.signUpWithEmail(email: email, password: password)

        switch result {
        case .failure(let e):
            return .failure(e.mapToDomainError())

        case .success(let outcomeDTO):

            // 1) session이 있으면: 가입 + 로그인까지 완료된 상태
            if let sessionDTO = outcomeDTO.session {

                // 2) 로그인 상태이므로 profiles upsert 가능(userId 있음)
                let upsert = await profileDataSource.upsertProfile(
                    userId: sessionDTO.userId,
                    email: email,
                    displayName: nil
                )
                if case .failure(let e) = upsert {
                    return .failure(e.mapToDomainError())
                }

                return .success(
                    .authenticated(
                        session: sessionDTO.toDomain(),
                        isNewUser: true
                    )
                )

            } else {
                // session이 nil이면 이메일 인증 필요 → 아직 로그인 아님
                return .success(
                    .emailVerificationRequired(email: outcomeDTO.email)
                )
            }
        }
    }

    // MARK: - Email 로그인
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        let result = await authDataSource.signInWithEmail(email: email, password: password)

        switch result {
        case .failure(let e):
            return .failure(e.mapToDomainError())

        case .success(let sessionDTO):

            // 로그인 성공 직후 profiles upsert
            let upsert = await profileDataSource.upsertProfile(
                userId: sessionDTO.userId,
                email: email,
                displayName: nil
            )
            if case .failure(let e) = upsert {
                return .failure(e.mapToDomainError())
            }

            return .success(
                .authenticated(
                    session: sessionDTO.toDomain(),
                    isNewUser: false
                )
            )
        }
    }

    // MARK: - 회원탈퇴
    /// Edge Function 등으로 “현재 로그인한 유저”를 서버에서 삭제합니다.
    func withdraw() async -> DomainResult<Void> {
        let result = await authDataSource.withdrawCurrentUser()

        switch result {
        case .success:
            return .success(())

        case .failure(let e):
            return .failure(e.mapToDomainError())
        }
    }
}

/*
 인증 상태 관리 구조
 
    AuthStateStore는 Presentation 계층에서 단일 인스턴스로 운용한다.
    RootCoordinator가 authState.subject를 구독하며,
    상태가 .signedIn 또는 .signedOut으로 변경되면 루트 화면을 전환한다.(예: 로그인 화면 ↔ 메인 화면)
 
    전역 인증 상태 변경은 UseCase 또는 ViewModel에서 수행한다.
    ViewModel이 Repository를 호출하고, 성공 시 authState.subject.send(...)를 통해 상태를 갱신한다.
    실패 시에는 에러만 처리한다.
    예시 흐름:
     •    ViewModel에서 authenticateWithApple() 호출
     •    성공하면 authState.subject.send(.signedIn(userId))
     •    로그아웃/탈퇴 성공 시 authState.subject.send(.signedOut)
 
    AuthStateStore(CurrentValueSubject<AuthState, Never>)가 담당한다.

*/
