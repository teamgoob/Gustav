//
//  AppleAuthProviding.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - Apple Auth Providing
// UseCase에는 로그인 결과만 제공
public protocol AppleAuthProviding {
    /// Apple 로그인 UI를 통해 idToken + nonce를 얻는다.
    func signIn() async throws -> AppleIDTokenResult
}
