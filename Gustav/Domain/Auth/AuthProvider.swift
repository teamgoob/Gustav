//
//  AuthProvider.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

// 도메인 규칙(로그인 방식의 의미)
public enum AuthProvider: String, Codable {
    case apple
    case email
    case unknown // 세션 복구 정확도를 위해서
}
