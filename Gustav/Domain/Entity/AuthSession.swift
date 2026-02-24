//
//  AuthSession.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - Auth Session 애플 로그인 결과 세션
public struct AuthSession: Equatable, Codable {
    public let accessToken: String      // API 요청 시 Authorization 헤더에 들어가는 토큰
    public let refreshToken: String     // accessToken 만료 시 새 토큰 발급용
    public let userId: UUID
    public let expiresAt: Date?         // 토큰 만료일
    public let provider: AuthProvider   // 로그인 방식


    public init(
        accessToken: String,
        refreshToken: String,
        userId: UUID,
        expiresAt: Date?,
        provider: AuthProvider
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
        self.expiresAt = expiresAt
        self.provider = provider
    }
}

///  그리고 data 영역에서 DTO를 만들어 두기로 했음. 다른 파일들은 codable, equatable을 사용하지 않음. 왜 이 파일에는 두어야함?
