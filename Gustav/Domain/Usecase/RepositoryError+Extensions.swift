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
    func mapToDomainError(_ error: RepositoryError) -> DomainError {
        switch error {
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
        default:
            return .unknown
        }
    }
}
