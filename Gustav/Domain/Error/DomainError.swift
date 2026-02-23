//
//  DomainError.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - Domain Layer Error
enum DomainError: Error {
    case authenticationRequired   // 인증 필요
    case permissionDenied         // 권한 없음
    case entityNotFound           // 데이터 없음
    case invalidOperation         // 제약 조건 충돌
    case temporarilyUnavailable   // 네트워크, 서버 오류
    case cancelled 
    case unknown                  // 그 외
}
