//
//  Result+Extensions.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/10.
//

import Foundation

// MARK: - Result Extension
// RepositoryResult -> DomainResult 변환 메서드 정의
extension Result where Failure == RepositoryError, Success: DomainConvertible{
    func toDomainResult() -> DomainResult<Success.DomainType> {
        // Success: DTO -> Entity 변환
        // Failure: RepositoryError -> DomainError 변환
        self
            .map { $0.toDomain() }
            .mapError { $0.mapToDomainError() }
    }
}
