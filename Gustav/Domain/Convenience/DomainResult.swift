//
//  DomainResult.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - Doman Error를 반환하는 Domain Layer Result
typealias DomainResult<T> = Result<T, DomainError>
