//
//  AuthDTO.swift
//  Gustav
//
//  Created by kaeun on 2/27/26.
//

import Foundation

struct AuthDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let userId: UUID
    let expiresAt: Date?
    let provider: String
}
