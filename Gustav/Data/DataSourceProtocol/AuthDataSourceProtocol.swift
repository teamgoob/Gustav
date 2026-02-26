//
//  AuthDataSourceProtocol.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

// Supabase Auth 호출 책임 분리용 DataSource 프로토콜

protocol AuthDataSourceProtocol {
    
    func signInWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthDTO>
    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthDTO>
    func refreshSession(refreshToken: String) async -> RepositoryResult<AuthDTO>
    
    func signUpWithEmail(email: String, password: String) async -> RepositoryResult<EmailSignUpOutcomeDTO>

    func signOut() async -> RepositoryResult<Void>
    func withdrawCurrentUser() async -> RepositoryResult<Void>

//AuthSessionRepository(또는 SessionStore) 에서 해결
//    func currentUserId() async -> RepositoryResult<UUID>

}




