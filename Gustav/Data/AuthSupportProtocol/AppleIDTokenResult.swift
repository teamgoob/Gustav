//
//  AppleIDTokenResult.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - Apple ID Token Result

struct AppleIDTokenResult: Equatable {
    let idToken: String
    let nonce: String

    // Apple은 최초 동의 시에만 내려줄 수 있음
    let email: String?
    let fullName: String?

    init(
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
