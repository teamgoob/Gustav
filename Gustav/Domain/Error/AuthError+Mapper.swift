//
//  AuthErrorToDomainErrorMapper.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation


// MARK: - AuthError Extension
extension AuthError {
    func mapToDomainError() -> DomainError {
        switch self {
        case .invalidEmailFormat,
             .emptyEmail,
             .emptyPassword,
             .weakPassword,
             .passwordMissingSpecialCharacter:
            return .invalidOperation
        }
    }
}

// MARK: - Error → DomainError
extension Error {
    func mapToDomainError() -> DomainError {
        if let e = self as? AuthError { return e.mapToDomainError() }
        if let e = self as? RepositoryError { return e.mapToDomainError() }
        if let e = self as? AppleAuthError { return e.mapToDomainError() }
        return .temporarilyUnavailable
    }
}
