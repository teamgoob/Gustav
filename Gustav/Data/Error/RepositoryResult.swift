//
//  RepositoryResult.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - Repository Error를 반환하는 Data Layer Result
typealias RepositoryResult<T> = Result<T, RepositoryError>
