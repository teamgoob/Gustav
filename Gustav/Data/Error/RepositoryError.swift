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
    case decoding            // DTO 변환 실패  (API 응답 구조 변경 등)
    
    case conflict            // 데이터 중복, 제약 조건 충돌
    
    case sessionNotFound     // 로컬 저장소에 세션이 존재하지 않음 (앱 시작 시 로그인 안 된 상태)

    case invalidCredentials  // 로그인 정보 오류 (잘못된 이메일/비밀번호, idToken/nonce 불일치 등)
    case misconfigured       // Supabase URL, anonKey, Apple Provider 설정 오류 등 환경 설정 문제
    
    case cancelled           // 사용자가 로그인 흐름을 직접 취소한 경우
    case rateLimited         // 너무 많은 로그인/회원가입 요청으로 서버가 차단한 경우 (예: 짧은 시간 내 반복 로그인 시도)
                             // → 네트워크 오류와 구분하여 처리 가능

    case emailNotVerified    // 이메일 인증이 완료되지 않은 계정으로 로그인 시도  → 단순 인증 실패와 구분
    
    case unknown             // 그 외
}
