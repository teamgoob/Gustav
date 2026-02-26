//
//  AppleAuthProviding.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import AuthenticationServices
// MARK: - Apple Auth Providing
// UseCase에는 로그인 결과만 제공 Apple SDK(AuthenticationServices) 감싸는 어댑터(Provider)

protocol AppleAuthProviding {
    /// Apple 로그인 UI를 띄울 창(anchor)을 외부에서 주입받는다.
    ///     ASPresentationAnchor는 UIKit의 UIWindow typealias
    func signIn(presentationAnchor: ASPresentationAnchor) async throws -> AppleIDTokenResult
}
