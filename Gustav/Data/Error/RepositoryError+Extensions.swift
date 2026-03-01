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
            
        case .decoding:
            return .unknown
            
        case .cancelled:
            return .cancelled
        case .rateLimited:
            return .temporarilyUnavailable
        case .emailNotVerified:
            return .authenticationRequired
            
        case .invalidCredentials:
            // idToken/nonce mismatch 등
            return .authenticationRequired
        case .misconfigured:
            // Supabase URL/Key/Provider 설정 오류
            return .temporarilyUnavailable
        case .sessionNotFound:
            /*  Repository에서 AuthOutcome.emailVerificationRequired로 변환 :: 나중에 presentation 계층 구현 이후에 수정해야하는 부분 */
            return .authenticationRequired
        
        default:
            return .unknown
        }
    }
}
