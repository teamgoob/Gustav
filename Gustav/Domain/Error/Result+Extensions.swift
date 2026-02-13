//
//  Result+Extensions.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/10.
//

import Foundation

// MARK: - Result Extension
// RepositoryResult -> DomainResult 변환 메서드 정의
extension Result where Failure == RepositoryError {
    func toDomainResult() -> DomainResult<Success> {
        self.mapError { $0.mapToDomainError() }
    }
}
