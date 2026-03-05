//
//  DomainError.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - Domain Layer Error
enum DomainError: Error {
    case authenticationRequired   // 인증 필요
    case permissionDenied         // 권한 없음
    case entityNotFound           // 데이터 없음
    case invalidOperation         // 제약 조건 충돌
    case invalidParameter         // 파라미터 오류
    case invalidInput(AuthInputError) // 입력값 오류 (Validator 결과)
    case temporarilyUnavailable   // 네트워크, 서버 오류
    case cancelled                // 사용자 취소(애플 로그인 등)
    case emailAlreadyInUse        // 회원가입: 이메일 중복
    case unknown                  // 그 외
}



enum AuthInputError: Equatable {
    case invalidEmailFormat                 // 이메일 형식 오류
    case emptyEmail                         // 빈 이메일
    case emptyPassword                      // 빈 비밀번호
    case passwordTooShort(minLength: Int)   // 비밀번호 최소 길이
    case passwordMissingSpecialCharacter    // 비밀번호 특수문자
    case emptyRepeatPassword
    case passwordMismatch
}
