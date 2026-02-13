//
//  RepositoryError+Extensions.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - RepositoryError Extension
// RepositoryError -> DomainError 변환 메서드 정의
extension RepositoryError {
    func mapToDomainError() -> DomainError {
        switch self {
        case .unauthorized:
            return .authenticationRequired
        case .forbidden:
            return .permissionDenied
        case .notFound:
            return .entityNotFound
        case .network:
            return .temporarilyUnavailable
        case .conflict:
            return .invalidOperation
            
        case .invalidCredentials:
            // idToken/nonce mismatch 등
            return .authenticationRequired
        case .misconfigured:
            // Supabase URL/Key/Provider 설정 오류
            return .temporarilyUnavailable
        case .sessionNotFound:
            return .authenticationRequired
        
        default:
            return .unknown
        }
    }
}
