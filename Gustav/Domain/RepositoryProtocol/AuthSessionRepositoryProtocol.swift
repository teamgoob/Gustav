//
//  AuthRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 인증 상태 및 세션 관리 Repository Protocol
// Supabase Auth 실제 호출하기 위한 repository

protocol AuthSessionRepositoryProtocol {

    // Apple 인증 (가입/로그인 통합) : 보통 처음이면 가입 아니면 로그인 방식으로 처리하기 때문에 분기하지 않음
    func authenticateWithApple() async -> DomainResult<AuthOutcome>

    // Email 회원가입
    func signUpWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome>

    // Email 로그인
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome>
    
    // 비밀번호 재설정 메일 발송
    func resetPassword(email: String) async -> DomainResult<Void>

    // recovery 세션에서 새 비밀번호로 갱신
    func updatePassword(newPassword: String) async -> DomainResult<Void>
    
    // 회원탈퇴
    func withdraw() async -> DomainResult<Void>
    
    // 현재 인증 provider 조회
    func currentAuthProvider() -> AuthProvider

}
