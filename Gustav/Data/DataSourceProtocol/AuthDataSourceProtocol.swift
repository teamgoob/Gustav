//
//  AuthDataSourceProtocol.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

// Supabase Auth 호출 책임 분리용 DataSource 프로토콜

protocol AuthDataSourceProtocol {
    
    func authenticateWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthDTO>
    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthDTO>
    
    // SDK가 이미 저장하고 있는 세션을 읽어오기 (없으면 nil)
    func currentSession() async -> RepositoryResult<AuthDTO?>

    // 검증 + 필요 시 refresh된 세션을 반환(없으면 nil)
    func validSession() async -> RepositoryResult<AuthDTO?>
    
    func signUpWithEmail(email: String, password: String) async -> RepositoryResult<EmailSignUpOutcomeDTO>

    // 비밀번호 재설정 메일 발송
    func resetPassword(email: String) async -> RepositoryResult<Void>

    func signOut() async -> RepositoryResult<Void>
    func withdrawCurrentUser() async -> RepositoryResult<Void>
    func currentAuthProvider() -> AuthProvider

    func currentUserId() -> UUID?

}




