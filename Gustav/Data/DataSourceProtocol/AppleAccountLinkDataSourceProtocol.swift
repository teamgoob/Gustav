//
//  AppleAccountLinkDataSourceProtocol.swift
//  Gustav
//
//  Created by kaeun on 3/27/26.
//

import Foundation

protocol AppleAccountLinkDataSourceProtocol {
    /// Apple 로그인 직후 authorizationCode를 서버에 전달하여
    /// Apple refresh token 저장에 필요한 연결 작업을 수행한다.
    /// - identityToken은 서버에서 Apple 사용자 식별(sub) 검증에 사용된다.
    func registerAppleAuthorizationCode(
        authorizationCode: String,
        identityToken: String
    ) async -> RepositoryResult<Void>

    /// 현재 로그인된 계정을 서버에서 삭제한다.
    /// 서버는 내부적으로 Apple revoke -> 도메인 데이터 삭제 -> Auth 유저 삭제를 수행한다.
    func withdrawCurrentAccount() async -> RepositoryResult<Void>
}
