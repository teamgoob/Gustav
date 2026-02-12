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

    public init(idToken: String, nonce: String) {
        self.idToken = idToken
        self.nonce = nonce
    }
}
