//
//  AuthSession.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - Auth Session 애플 로그인 토근
public struct AuthSession: Equatable, Codable {
    public let accessToken: String      // API 요청 시 Authorization 헤더에 들어가는 토큰
    public let refreshToken: String     // accessToken 만료 시 새 토큰 발급용
    public let userId: String
    public let expiresAt: Date?         // 토큰 만료일

    public init(accessToken: String, refreshToken: String, userId: String, expiresAt: Date?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
        self.expiresAt = expiresAt
    }
}
