//
//  AppleIDTokenResult.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - Apple ID Token Result

public struct AppleIDTokenResult: Equatable {
    public let idToken: String
    public let nonce: String

    // Apple은 최초 동의 시에만 내려줄 수 있음
    public let email: String?
    public let fullName: String?

    public init(
        idToken: String,
        nonce: String,
        email: String?,
        fullName: String?
    ) {
        self.idToken = idToken
        self.nonce = nonce
        self.email = email
        self.fullName = fullName
    }
}
