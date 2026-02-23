//
//  RepositoryError.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - Data Layer Error
// Supabase Error를 Repository Error로 변환
enum RepositoryError: Error {
    case unauthorized        // 인증 안 됨, 세션 만료
    case forbidden           // RLS 차단
    case notFound            // 데이터 없음
    case network             // 네트워크, 서버 오류
    case decoding            // DTO 변환 실패
    case conflict            // 데이터 중복, 제약 조건 충돌
    
    case sessionNotFound     // 로컬 세션 없음
    
    case invalidCredentials  // 토큰/nonce 검증 실패, 잘못된 로그인 정보
    case misconfigured       // URL/anonKey/provider 설정 등 환경 문제
    case unknown             // 그 외
}
