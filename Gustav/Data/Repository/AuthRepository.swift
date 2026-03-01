//
//  AuthRepository.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//
import Foundation

// - AppleAuthProviding(Apple SDK 래퍼)로 idToken/nonce/email/fullName을 얻고
// - AuthDataSourceProtocol(Supabase 호출)로 세션을 만들고
// - ProfileRepositoryProtocol로 profiles bootstrap(없으면 생성/있으면 보정)을 수행하며
// - 마지막으로 DomainResult로 변환해서 상위(UseCase/VM)에 반환한다

final class AuthRepository: AuthRepositoryProtocol {
    
    // appleProvider: Apple SDK(AuthenticationServices)를 감춘 래퍼.
    private let appleProvider: AppleAuthProviding
    private let dataSource: AuthDataSourceProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let sessionStore: SessionStore
    init(
        appleProvider: AppleAuthProviding,
        dataSource: AuthDataSourceProtocol,
        profileRepository: ProfileRepositoryProtocol,
        sessionStore: SessionStore
    ) {
        self.appleProvider = appleProvider
        self.dataSource = dataSource
        self.profileRepository = profileRepository
        self.sessionStore = sessionStore
    }
    
    
    // Apple 로그인 기반 - 가입
    // - session: 생성된 AuthSession
    // - result: SignUpResult(.signedUp / .alreadyExists 등)로 신규/기존 판단을 상위에 전달
    func signUpWithApple() async -> DomainResult<(session: AuthSession, result: AuthOutcome)> {
        do {
            // 1) Apple 로그인 UI를 띄우고 성공 시 토큰/nonce/email/fullName을 얻는다.
            let token = try await appleProvider.signIn()
            let hint = try? await dataSource.currentUserProfileHint().get()
            
            // 2) Supabase Auth에 idToken + nonce로 로그인 요청(세션 생성)
            let signResult = await dataSource.signInWithApple(idToken: token.idToken, nonce: token.nonce)
            
            switch signResult {
            case .failure(let error): // Supabase 로그인 실패(401/403/network 등)
                return .failure(error.mapToDomainError())
                
            case .success(let session):  // Supabase 로그인 성공 → AuthSession 확보
                guard let userId = UUID(uuidString: session.userId) else {
                    return .failure(.unknown)
                }
                
                let bootstrap = await profileRepository.bootstrapAfterAppleAuth(
                    userId: userId,
                    email: token.email,
                    fullName: token.fullName,
                    policy: .strict
                    
                )
                
                
                // 3) 우리 앱의 profiles 테이블에 프로필이 있는지 확인/생성/보정
                switch bootstrap {
                case .failure(let e):
                    return .failure(e)
                case .success(let created):
                    return .success((session: session, result: created ? .signedUp : .alreadyExists))
                }
            }
        } catch {
            // appleProvider.signIn() 과정에서 throw
            // 예: 사용자 취소, presentation anchor 없음, credential 없음 등(AppleAuthError)
            return .failure(error.mapToDomainError())
        }
    }
    
    // Apple 로그인 기반 - 로그인
    // signUpWithApple과 다르게 SignUpResult를 반환하지 않고 세션만 반환
    func signInWithApple() async -> DomainResult<AuthSession> {
        do {
            let token = try await appleProvider.signIn()
            let signResult = await dataSource.signInWithApple(idToken: token.idToken, nonce: token.nonce)
            
            switch signResult {
            case .failure(let e):
                return .failure(e.mapToDomainError())
                
            case .success(let session):

                guard let userId = UUID(uuidString: session.userId) else {
                    return .failure(.unknown) // userId 파싱 실패는 내부 데이터 이상
                }

                let bootstrap = await profileRepository.bootstrapAfterAppleAuth(
                    userId: userId,
                    email: token.email,
                    fullName: token.fullName,
                    policy: .strict
                )

                switch bootstrap {
                case .success:
                    return .success(session)
                case .failure(let e):
                    return .failure(e)
                }
            }
        } catch {
            return .failure(error.mapToDomainError())
        }
    }
    
    // 이메일/비번 로그인
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthSession> {
        let result = await dataSource.signInWithEmail(email: email, password: password).toDomain()
        guard case .success(let session) = result else {
            return result
        }
        
        if let userId = UUID(uuidString: session.userId) {
            _ = await profileRepository.bootstrapAfterAppleAuth(
                userId: userId,
                email: email,
                fullName: nil,
                policy: .strict
                
            )
        }
        
        return .success(session)
    }
    
    // 이메일/비번 회원가입
    func signUpWithEmail(
        email: String,
        password: String
    ) async -> DomainResult<(session: AuthSession?, result: SignUpResult)> {
        let result = await dataSource.signUpWithEmail(email: email, password: password)
        switch result {
        case .failure(let e):
            return .failure(e.mapToDomainError())
            
        case .success(let output):
            if output.requiresEmailVerification || output.session == nil {
                return .success((session: nil, result: .verificationRequired))
            }
            
            guard let session = output.session else {
                return .failure(.unknown)
            }
            
            if let userId = UUID(uuidString: session.userId) {
                _ = await profileRepository.bootstrapAfterAppleAuth(
                    userId: userId,
                    email: email,
                    fullName: nil,
                    policy: .strict
                    
                )
            }
            
            return .success((session: session, result: .signedUp))
        }
    }
    
    func signOut() async -> DomainResult<Void> {
        await dataSource.signOut().toDomain()
    }
    
    
    func withdraw(reauth method: ReauthMethod) async -> DomainResult<Void> {

        // 재인증 먼저 수행
        let reauthResult = await performReauth(method)
        guard case .success = reauthResult else {
            return reauthResult
        }

        // 서버에서 계정 삭제
        let result = await dataSource.withdrawCurrentUser().toDomain()
        switch result {
        case .failure:
            return result
        case .success:
            // 로컬 세션 정리
            do {
                try sessionStore.clear()
                return .success(())
            } catch {
                return .failure(error.mapToDomainError())
            }
        }
    }
    
    // 현재 로그인된 유저의 UUID 반환
    func currentUserId() async -> DomainResult<UUID> {
        await dataSource.currentUserId().toDomain()
    }
    
    
    private func performReauth(_ method: ReauthMethod) async -> DomainResult<Void> {
            switch method {
                
            case .apple:
                do {
                    let token = try await appleProvider.signIn()
                    let result = await dataSource.signInWithApple(
                        idToken: token.idToken,
                        nonce: token.nonce
                    )
                    return result.toDomain().map { _ in () }
                } catch {
                    return .failure(error.mapToDomainError())
                }
                
            case .email(let email, let password):
                let result = await dataSource.signInWithEmail(
                    email: email,
                    password: password
                )
                return result.toDomain().map { _ in () }
            }
        }
    
}
