//
//  AuthRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 인증 상태 및 세션 관리 Repository Protocol
// Supabase Auth 실제 호출하기 위한 repository

protocol AuthFlowRepositoryProtocol {

    // 세션 복구(자동 로그인) / 필요 시 refresh
    func restoreSession() async -> DomainResult<AuthSession?>

    // 로그아웃
    func signOut() async -> DomainResult<Void>

    // 회원탈퇴
    func withdraw(reauth: ReauthMethod) async -> DomainResult<Void>

    // 현재 로그인 유저 id 조회
    func currentUserId() -> UUID?
}
