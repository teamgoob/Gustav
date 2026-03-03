//
//  RepositoryErrorConvertible.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation
import Supabase

// MARK: - RepositoryErrorConvertible
// Repository Error로 변환 가능한 에러 타입
protocol RepositoryErrorConvertible {
    func mapToRepositoryError() -> RepositoryError
}

// PostgrestError -> RepositoryError 변환 메서드 정의
extension PostgrestError: RepositoryErrorConvertible {
    func mapToRepositoryError() -> RepositoryError {
        // 에러 코드 검사
        switch self.code {
        // 유니크 제약 조건 위반
        case "23505":
            return .conflict
            
        // 외래 키 제약 조건 위반
        case "23503":
            return .conflict
            
        // 권한 없음 (RLS 정책 포함)
        case "42501":
            return .forbidden
            
        default:
            break
        }
        
        // 에러 메세지 검사
        let message = self.message.lowercased()
        
        if message.contains("permission denied") {
            return .forbidden
        }
        
        return .unknown
    }
}

// URLError -> RepositoryError 변환 메서드 정의
extension URLError: RepositoryErrorConvertible {
    func mapToRepositoryError() -> RepositoryError {
        return .network
    }
}

// DecodingError -> RepositoryError 변환 메서드 정의
extension DecodingError: RepositoryErrorConvertible {
    func mapToRepositoryError() -> RepositoryError {
        return .decoding
    }
}
