//
//  AuthUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 인증 상태 및 세션 관리 Usecase
// 애플 로그인 기반 수정 필요
protocol AuthUsecaseProtocol {
    // 앱 시작 시 호출하여 Supabase 세션 복원 시도
    // 성공: 로그인 상태 유지
    // 실패: 비로그인 상태
    func restoreSession() async -> DomainResult<Void>
    
    // 회원 가입
    func signUp() async -> DomainResult<Void>

    // 로그인
    func signIn() async -> DomainResult<Void>

    // 로그아웃, 로컬 세션 제거
    func signOut() async -> DomainResult<Void>

    // 회원 탈퇴, Auth 계정 삭제
    func withdraw() async -> DomainResult<Void>
}

// 애플 로그인 기반 수정 필요
final class AuthUsecase: AuthUsecaseProtocol {
    func restoreSession() async -> DomainResult<Void> {
        <#code#>
    }
    
    func signUp() async -> DomainResult<Void> {
        <#code#>
    }
    
    func signIn() async -> DomainResult<Void> {
        <#code#>
    }
    
    func signOut() async -> DomainResult<Void> {
        <#code#>
    }
    
    func withdraw() async -> DomainResult<Void> {
        <#code#>
    }
}
