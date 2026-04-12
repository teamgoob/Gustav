//
//  TestAuthUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/6.
//

import Foundation

// MARK: - TestAuthUsecase
// UI 테스트용 AuthUsecase
final class TestAuthUsecase: AuthUseCaseProtocol {
    func currentAuthProvider() -> AuthProvider {
        return .unknown
    }
    
    func resetPassword(email: String) async -> DomainResult<Void> {
        return .failure(.unknown)

    }
    
    func restoreSession() async -> DomainResult<AuthSession?> {
        return .failure(.unknown)
    }
    
    func authenticateWithApple() async -> DomainResult<AuthOutcome> {
        return .failure(.unknown)
    }
    
    func signUpWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        return .failure(.unknown)
    }
    
    func signInWithEmail(email: String, password: String) async -> DomainResult<AuthOutcome> {
        return .failure(.unknown)
    }
    
    func signOut() async -> DomainResult<Void> {
        return .failure(.unknown)
    }
    
    func withdraw() async -> DomainResult<Void> {
        return .failure(.unknown)
    }
    
    func currentUserId() -> UUID? {
        return UUID()
    }
}
