//
//  AuthErrorToDomainErrorMapper.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// DomainError 매핑
enum AuthErrorToDomainErrorMapper {
    
    static func mapToDomainError(_ error: Error) -> DomainError {
        if let e = error as? AuthError {
            switch e {
            case .invalidEmailFormat, .emptyEmail, .emptyPassword, .weakPassword,
                    .passwordMissingSpecialCharacter:
                return .invalidOperation
            case .sessionNotFound:
                return .authenticationRequired
            }
        }

        if let e = error as? AppleAuthError {
            switch e {
            case .inProgress, .missingPresentationAnchor:
                return .invalidOperation
            case .invalidCredential, .missingNonce, .missingIdentityToken:
                return .authenticationRequired
            case .cancelled:
                return .unknown
            }
        }
        
        // Supabase / 네트워크 / 알 수 없는 에러
        return .temporarilyUnavailable
    }
}
