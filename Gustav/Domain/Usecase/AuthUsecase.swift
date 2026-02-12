//
//  AuthUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation


// MARK: - 분기 결과
enum SessionRestoreResult {
    case restored   // 로그인 유지
    case notRestored // 비로그인
}

enum SignUpResult {
    case signedUp    // 신규 가입 완료
    case alreadyExists // 이미 계정 있음(가입이 아니라 로그인으로 유도)
}

// MARK: - 사용자 인증 상태 및 세션 관리 Usecase
// 애플 로그인 + 이메일비번 기반
protocol AuthUsecaseProtocol {
    // 앱 시작 시 호출하여 Supabase 세션 복원 시도
    // 성공: 로그인 상태 유지
    // 실패: 비로그인 상태
    func restoreSession() async -> DomainResult<SessionRestoreResult>
    
    // 회원 가입
    func signUpWithApple() async -> DomainResult<SignUpResult>
    func signUpWithEmail(email: String, password: String) async -> DomainResult<SignUpResult>
    
    // 로그인
    func signInWithApple() async -> DomainResult<Void>
    func signInWithEmail(email: String, password: String) async -> DomainResult<Void>
    
    // 로그아웃, 로컬 세션 제거
    func signOut() async -> DomainResult<Void>

    // 회원 탈퇴, Auth 계정 삭제
    func withdraw() async -> DomainResult<Void>
}

// MARK: - 유스케이스 구현부
final class AuthUsecase: AuthUsecaseProtocol {
    private let appleProvider: AppleAuthProviding // 토큰 결과
    private let authRepository: AuthRepositoryProtocol // repo 프로토콜
    private let sessionStore: SessionStore // 세션 저장/조회/삭제
    
    init(appleProvider: AppleAuthProviding, authRepository: AuthRepositoryProtocol, sessionStore: SessionStore) {
        self.appleProvider = appleProvider
        self.authRepository = authRepository
        self.sessionStore = sessionStore
    }
    
    // 앱 시작 시 로그인 상태를 결정
    // 로그인 상태로 시작 or 로그인 화면으로
    func restoreSession() async -> DomainResult<SessionRestoreResult> {
        /// 로컬에 세션이 있고, 만료되지 않았다면 로그인 유지
        /// 만료되었다면 서버에 갱신시도, 실패하면 비로그인 처리
        
        do {
            // 1) 로컬 세션 로드 : 세션의 존재 유무
            guard let local = try sessionStore.load() else {
                // 비로그인 -> 로그인 화면
                return .success(.notRestored)
            }
            
            // 2) 만료 시간이 있고, 지금보다 만료 시간이 미래라면 로그인 유지
            if let expiresAt = local.expiresAt, expiresAt > Date() {
                return .success(.restored) // 로그인 유지
            }
            
            // 3) 만료면 repo에 갱신 위임 (Result로 받음)
            let repoResult = await authRepository.restoreOrRefreshSession(from: local)
            
            switch repoResult {
            case .success(let refreshed):
                // 4) 성공 시 저장 후 로그인 유지
                try sessionStore.save(refreshed)
                return .success(.restored)
                
            case .failure:
                // 5) 실패 시 세션 제거 후 비로그인 확정
                //  서버 기준으로 로그인 유지 불가
                try? sessionStore.clear()
                return .success(.notRestored)
            }
        } catch {
            // 로컬 기준으로 로그인 유지 불가
            try? sessionStore.clear()
            return .success(.notRestored)
        }
    }
    
    
    // 애플 아이디로 회원가입
    func signUpWithApple() async -> DomainResult<SignUpResult> {
        do {
            // 1) Apple 로그인 UI → idToken + nonce 획득
            let token = try await appleProvider.signIn()
            
            // 2) repo 호출 (Result로 받음)
            let repoResult = await authRepository.signUpWithApple(
                idToken: token.idToken,
                nonce: token.nonce
            )
            
            let domainRepo = repoResult.toDomainResult()
            
            switch domainRepo {
            case .success(let output):
                // 3) 세션 저장
                try sessionStore.save(output.session)
                // 4) 가입 결과 반환
                return .success(output.result)
                
            case .failure(let domainError):
                return .failure(domainError)
            }

    
        } catch let e as AppleAuthError where e == .cancelled {
            // 사용자가 취소한 케이스 : 보통 화면에서 그냥 무시하고 머무는 게 자연스러움 -> 에러나 실패가 아님
            // SignUpResult에 cancelled가 없음. DomainError unknown으로 처리
            return .failure(.cancelled)
            
        } catch {
            // 진짜 에러
            return .failure(error.mapToDomainError())
        }
        
    }
    
    // 이메일로 회원가입
    func signUpWithEmail(email: String, password: String) async -> DomainResult<SignUpResult> {
        do {
            // 0) 입력 검증
            try validateEmailPassword(email: email, password: password)

            // 1) repository 호출 (Result)
            let repoResult = await authRepository.signUpWithEmail(email: email, password: password)

            // 2) RepositoryResult -> DomainResult로 변환
            let domainRepo = repoResult.toDomainResult()

            switch domainRepo {
            case .success(let output):
                // 3) 세션 저장 (로그인 유지)
                try sessionStore.save(output.session)

                // 4) 가입 결과 반환 (신규/기존)
                return .success(output.result)
                
                // 레포지토리에서 발생한 것
                // 서버/DB/네트워크 : 외부 실패
            case .failure(let domainError):
                return .failure(domainError)
            }

        } catch {
            // 유스케이스 내부에서 발생
            // 입력검증, SDK, 로컬저장 : 내부 실패
            return .failure(error.mapToDomainError())
        }
    }
    
    // 애플 로그인
    func signInWithApple() async -> DomainResult<Void> {
        do {
            // 1) Apple 로그인 UI → idToken + nonce 획득 (throws)
            let token = try await appleProvider.signIn()

            // 2) Repository 호출 → 세션 획득 (Result)
            let repoResult = await authRepository.signInWithApple(
                idToken: token.idToken,
                nonce: token.nonce
            )

            // 3) RepositoryResult -> DomainResult 변환
            let domainRepo: DomainResult<AuthSession> = repoResult.toDomainResult()

            switch domainRepo {
                //authRepository.signInWithApple가 서버(Supabase)에서 받아온 AuthSession
            case .success(let session):
                // 4) 세션 저장 (로그인 유지)
                try sessionStore.save(session)
                return .success(())

            case .failure(let domainError):
                return .failure(domainError)
            }

        } catch let e as AppleAuthError where e == .cancelled {
            // 사용자가 취소: 보통 에러로 취급하지 않고 "아무 일도 없음"으로 종료
            return .success(())

        } catch {
            // AppleAuthProvider / SessionStore 등에서 throw된 에러
            return .failure(error.mapToDomainError())
        }
    }
    
    // 이메일로 로그인
    func signInWithEmail(email: String, password: String) async -> DomainResult<Void> {
        do {
            // 0) 입력 검증 (이메일/비밀번호 정책)
            try validateEmailPassword(email: email, password: password)

            // 1) Repository 호출 → 세션 획득
            let repoResult = await authRepository.signInWithEmail(
                email: email,
                password: password
            )

            // 2) RepositoryResult -> DomainResult 변환
            let domainRepo: DomainResult<AuthSession> = repoResult.toDomainResult()

            switch domainRepo {
            case .success(let session):
                // 3) 세션 저장 (로그인 유지)
                try sessionStore.save(session)
                return .success(())

            case .failure(let domainError):
                // 서버/네트워크/인증 실패
                return .failure(domainError)
            }

        } catch {
            // 입력 검증 실패(AuthError) 또는 세션 저장 실패
            return .failure(error.mapToDomainError())
        }
    }
    
    // 로그아웃
    func signOut() async -> DomainResult<Void> {
        // 1) 서버 로그아웃 시도 (실패해도 흐름 유지)
        let repoResult = await authRepository.signOut()

        // 2) 로컬 세션 제거는 무조건 수행
        try? sessionStore.clear()

        // 3) 서버 로그아웃 실패를 사용자에게 노출할지 정책 선택
        switch repoResult {
        case .success:
            return .success(())

        case .failure:
            // 대부분의 경우 실패여도 성공 처리
            return .success(())
        }
    }
    
    //회원 탈퇴
    func withdraw() async -> DomainResult<Void> {
        // 1) 서버에 "데이터 삭제 + Auth 유저 삭제" 요청
        let repoResult = await authRepository.withdraw()
        let domainRepo: DomainResult<Void> = repoResult.toDomainResult()

        // 2) 로컬 세션은 항상 제거 시도
        do {
            try sessionStore.clear()
        } catch {
            return .failure(error.mapToDomainError())
        }

        // 3) 서버 결과 반환
        switch domainRepo {
        case .success:
            // 서버 삭제 성공 + 로컬 세션 삭제 성공
            return .success(())

        case .failure(let domainError):
            // 서버 삭제 실패(네트워크/권한/서버오류 등)
            // 로컬은 이미 clear 됐으니 앱에서는 로그아웃 상태
            return .failure(domainError)
        }
    }
    
    
    // MARK: - 비밀번호 입력 검증

    private func validateEmailPassword(email: String, password: String) throws {
        
        // 공백문자/줄바꿈 제거
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 공백일 경우 -> 이메일이 비었음
        if trimmedEmail.isEmpty { throw AuthError.emptyEmail }
        
        // 비밀번호가 비었음
        if password.isEmpty { throw AuthError.emptyPassword }

        // 간단 이메일 형식 체크 -> 진짜 이메일 여부는 서버에서.
        if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            throw AuthError.invalidEmailFormat
        }
        
        // 비밀번호 최소 글자 8자
        let minLength = 8
        if password.count < minLength {
            throw AuthError.weakPassword(minLength: minLength)
        }

        // 특수문자 1개 이상(영숫자 아닌 문자)
        let specialSet = CharacterSet.alphanumerics.inverted // 특수문자 모음
        if password.rangeOfCharacter(from: specialSet) == nil {
            throw AuthError.passwordMissingSpecialCharacter
        }
    }

}

