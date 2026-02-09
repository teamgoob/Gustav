//
//  AuthRepositoryProtocol.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 인증 상태 및 세션 관리 Repository Protocol
// 애플 로그인 기반 수정 필요
protocol AuthRepositoryProtocol {
    // 현재 세션 복구 (자동 로그인)
    func restoreSession() -> RepositoryResult<Void>

    // 회원 가입
    func signUp() -> RepositoryResult<Void>

    // 로그인
    func signIn() -> RepositoryResult<Void>

    // 로그아웃
    func signOut() -> RepositoryResult<Void>

    // 회원 탈퇴
    func withdraw() -> RepositoryResult<Void>
}
