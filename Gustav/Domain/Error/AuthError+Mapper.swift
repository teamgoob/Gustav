//
//  AuthErrorToDomainErrorMapper.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation


// MARK: - AuthError Extension
extension AuthError {
    func authToDomainError() -> DomainError {
        switch self {
        case .invalidEmailFormat,
             .emptyEmail,
             .emptyPassword,
             .weakPassword,
             .passwordMissingSpecialCharacter:
            return .invalidOperation

        case .sessionNotFound:
            return .authenticationRequired
        }
    }
}

// MARK: - AppleAuthError Extension
extension AppleAuthError {
    func authToDomainError() -> DomainError {
        switch self {
        case .inProgress,
             .missingPresentationAnchor:
            return .invalidOperation

        case .invalidCredential,
             .missingNonce,
             .missingIdentityToken:
            return .authenticationRequired

        case .cancelled:// 성공처리
            return .unknown
        }
    }
}

// MARK: - Error → DomainError
extension Error {
    func authToDomainError() -> DomainError {
        if let e = self as? AuthError { return e.authToDomainError() }
        if let e = self as? AppleAuthError { return e.authToDomainError() }
        if let e = self as? RepositoryError { return e.mapToDomainError() }
        return .temporarilyUnavailable
    }
}
