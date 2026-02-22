//
//  AuthDataSourceProtocol.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

// Supabase Auth 호출 책임 분리용 DataSource 프로토콜

protocol AuthDataSourceProtocol {
    
    func restoreOrRefreshSession(from local: AuthSession) async -> RepositoryResult<AuthSession>
    
    func signInWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthSession>
    
    func signOut() async -> RepositoryResult<Void>
    
    func currentUserId() async -> RepositoryResult<UUID>
}
