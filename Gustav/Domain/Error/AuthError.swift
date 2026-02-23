//
//  AuthError.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - Auth Error
public enum AuthError: Error, Equatable {
    case invalidEmailFormat                 // 형식오류
    case weakPassword(minLength: Int)       // 비밀번호 정책 위반
    case passwordMissingSpecialCharacter    // 특수문자
    case emptyPassword                      // 비밀 번호 비어 있음
    case emptyEmail                         // 이메일 비어 있음
}


