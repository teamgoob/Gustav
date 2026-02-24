//
//  AuthUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation


// MARK: - 분기 결과
// presentation 구현 후에 상태 분기 코드 수정/ 업데이트 필요
enum SessionRestoreResult {
    case restored   // 로그인 유지
    case notRestored // 비로그인
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
    func withdraw(reauth method: ReauthMethod) async -> DomainResult<Void>
}

// MARK: - 유스케이스 구현부
final class AuthUsecase: AuthUsecaseProtocol {

    // repo 프로토콜
    private let authRepository: AuthRepositoryProtocol
    // 세션 저장/조회/삭제
    private let sessionStore: SessionStore

    init(authRepository: AuthRepositoryProtocol, sessionStore: SessionStore) {
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
        // 레포지토리 호출
        let repoResult = await authRepository.signUpWithApple()

        switch repoResult {
        case .success(let output):
            do {
                // 세션 저장 시도
                try sessionStore.save(output.session)
                return .success(output.result)
            } catch {
                // 저장 실패 시
                return .failure(error.mapToDomainError())
            }
        case .failure(let error):
            return .failure(error)
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
            let domainRepo = repoResult

            switch domainRepo {
            case .success(let output):
                // 3) 세션이 있으면 저장 (로그인 유지)
                if let session = output.session {
                    try sessionStore.save(session)
                }

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
        let repoResult = await authRepository.signInWithApple()

        switch repoResult {
        case .success(let session):
            do {
                try sessionStore.save(session)
                return .success(())
            } catch {
                return .failure(error.mapToDomainError())
            }
        case .failure(let error):
            return .failure(error)
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
            let domainRepo: DomainResult<AuthSession> = repoResult

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
    func withdraw(reauth method: ReauthMethod) async -> DomainResult<Void> {

        // 1) 서버 탈퇴(재인증 + 계정 삭제)
        let result = await authRepository.withdraw(reauth: method)

        // 2) 성공했을 때만 로컬 세션 정리
        switch result {
        case .failure:
            return result

        case .success:
            do {
                try sessionStore.clear()
                return .success(())
            } catch {
                // 서버는 탈퇴 성공했는데 로컬 정리 실패
                // => 앱은 이미 "로그아웃 상태"로 유도해야 해서,
                //    여기서는 에러로 막기보다 unknown 처리하거나 성공 반환하는 편이 안전함(정책 선택)
                return .failure(error.mapToDomainError())
            }
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
