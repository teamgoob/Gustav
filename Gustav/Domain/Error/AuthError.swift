//
//  AuthError.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation


// MARK: - Apple Auth Error

public enum AppleAuthError: Error, Equatable {
    case invalidCredential // Apple SDK에서 기대한 credential 아님
    case missingNonce // 내부 상태 꼬임
    case missingIdentityToken // Apple 응답에 토큰 없음
    case inProgress // 로그인 중 재호출
    case cancelled // 사용자가 취소
    case missingPresentationAnchor // UI 띄울 window 없음
    // 재인증 필요
    // 계정 잠김
}

// MARK: - Auth Error
public enum AuthError: Error, Equatable {
    case invalidEmailFormat                 // 형식오류
    case weakPassword(minLength: Int)       // 비밀번호 정책 위반
    case passwordMissingSpecialCharacter    // 특수문자
    case emptyPassword                      // 비밀 번호 비어 있음
    case emptyEmail                         // 이메일 비어 있음
    case sessionNotFound                    // 로컬 세션 없음
}


