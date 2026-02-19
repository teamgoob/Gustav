//
//  Result+Extensions.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/10.
//

import Foundation

// MARK: - Result Extension
// 단일 DTO: RepositoryResult -> DomainResult 변환 메서드 정의
extension Result where Failure == RepositoryError, Success: DomainConvertible{
    func toDomainResult() -> DomainResult<Success.DomainType> {
        // Success: DTO -> Entity 변환
        // Failure: RepositoryError -> DomainError 변환
        self
            .map { $0.toDomain() }
            .mapError { $0.mapToDomainError() }
    }
}

// DTO 배열: RepositoryResult -> DomainResult 변환 메서드 정의
extension Result where Failure == RepositoryError, Success: Collection, Success.Element: DomainConvertible {
    func toDomainResult() -> DomainResult<[Success.Element.DomainType]> {
        // Success: [DTO] -> [Entity] 변환
        // Failure: RepositoryError -> DomainError 변환
        self
            .map { collection in
                collection.map { $0.toDomain() }
            }
            .mapError { $0.mapToDomainError() }
    }
}

// Void 타입: RepositoryResult -> DomainResult 변환 메서드 정의
extension Result where Failure == RepositoryError, Success == Void {
    func toDomainResult() -> DomainResult<Void> {
        self.mapError { $0.mapToDomainError() }
    }
}
