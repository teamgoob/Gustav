//
//  AuthRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 인증 상태 및 세션 관리 Repository Protocol
// Supabase Auth 실제 호출하기 위한 repository

protocol AuthRepositoryProtocol {
    // 세션 복구(자동 로그인) / 필요 시 refresh
    func restoreOrRefreshSession(from local: AuthSession) async -> RepositoryResult<AuthSession>
        ///로컬 세션을 받으면 세션을 기반으로 서버에서 복구하거나, 새 세션을 만들어서 돌려줘라
    
    // 애플 회원가입
    func signUpWithApple(idToken: String, nonce: String) async -> RepositoryResult<(session: AuthSession, result: SignUpResult)>
    
    // 이메일 회원가입
    func signUpWithEmail(
        email: String,
        password: String
    ) async -> RepositoryResult<(session: AuthSession, result: SignUpResult)>
    
    // 애플 로그인 (성공하면 세션 반환)
    func signInWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthSession>
    
    // 이메일 로그인
    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthSession>

    func signOut() async -> RepositoryResult<Void>

    // 회원탈퇴(대개 서버 함수 필요)
    func withdraw() async -> RepositoryResult<Void>
    
    
    // 현재 로그인 유저 id 조회
    func currentUserId() async -> RepositoryResult<UUID>
}
