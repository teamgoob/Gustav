//
//  DefaultAuthValidator.swift
//  Gustav
//
//  Created by kaeun on 3/5/26.
//


import Foundation

// MARK: - Default Auth Validator
struct DefaultAuthValidator: AuthValidatorProtocol {

    // 이메일 검증 함수
    /// 로그인, 회원가입에서 모두 쓰임
    func validateEmail(_ email: String) -> AuthInputError? {

        // 공백제거
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        // 빈 이메일인지 확인
        if trimmed.isEmpty {
            return .emptyEmail
        }

        // 이메일 형식 검증 : 이메일 regex 패턴
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        // regex 검사
        let isValid = trimmed.range(
            of: pattern,
            options: [.regularExpression, .caseInsensitive] // 정규식 + 대소문자 무시
        ) != nil

        return isValid ? nil : .invalidEmailFormat
    }

    // 비밀번호 검증 함수
    func validatePassword(_ password: String, minLength: Int) -> AuthInputError? {

        // 빈 비밀번호인지 확인
        if password.isEmpty {
            return .emptyPassword
        }

        // 비밀번호 최소길이 확인
        if password.count < minLength {
            return .passwordTooShort(minLength: minLength)
        }

        let hasLetter = password.unicodeScalars.contains {
            CharacterSet.letters.contains($0)
        }
        let hasDigit = password.unicodeScalars.contains {
            CharacterSet.decimalDigits.contains($0)
        }

        if !hasLetter || !hasDigit {
            return .passwordMissingLetterOrDigit
        }

        return nil
    }

    // 비밀번호 재입력 검증
    func validateRepeatPassword(
        password: String,
        repeatPassword: String
    ) -> AuthInputError? {

        // 빈 재입력 칸인지 확인
        if repeatPassword.isEmpty {
            return .emptyRepeatPassword
        }

        // 원본 비밀번호 확인
        if password.isEmpty {
            return .emptyPassword
        }

        // 비밀번호 일치 검사
        if password != repeatPassword {
            return .passwordMismatch
        }

        return nil
    }
    
    // 로그인에서 비밀번호 검증함수
    func validateSignInPassword(_ password: String) -> AuthInputError? {
        if password.isEmpty { return .emptyPassword }
        return nil
    }
}
