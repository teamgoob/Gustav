//
//  AuthValidatorProtocol.swift
//  Gustav
//
//  Created by kaeun on 3/5/26.
//

import Foundation

// MARK: - Auth Input Validation Protocol
protocol AuthValidatorProtocol {

    /// 이메일 형식 검증
    /// - Returns: 오류가 있으면 AuthInputError, 없으면 nil
    func validateEmail(_ email: String) -> AuthInputError?

    /// 비밀번호 정책 검증
    func validatePassword(_ password: String, minLength: Int) -> AuthInputError?

    /// 비밀번호 재입력 검증
    func validateRepeatPassword(
        password: String,
        repeatPassword: String
    ) -> AuthInputError?
    
    /// 로그인 검증 함수
    func validateSignInPassword(_ password: String) -> AuthInputError?
}
