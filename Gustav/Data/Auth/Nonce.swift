//
//  Nonce.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation
import CryptoKit

// MARK: - Apple 로그인용 nonce생성 유틸리티
//Apple에 전달할 SHA-256 해시값을 만들기 위한 유틸리티
///     Apple request에는 sha256(nonce)
///     Supabase에는 원문 nonce
enum Nonce {
    static func randomString(length: Int = 32) -> String {
        precondition(length > 0) // 실행 중 조건이 false면 즉시 크래시
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = "" // 최종 nonce
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16) // 16 바이트
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms) // iOS의 CSPRNG(암호학적으로 안전한 난수 생성기)
            if status != errSecSuccess { fatalError("Unable to generate nonce") } // 실패 처리

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    // Apple 요청에 넣을 hashed nonce 생성용
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
