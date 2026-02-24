//
//  AuthOutcome.swift
//  Gustav
//
//  Created by kaeun on 2/25/26.
//

// 유저의 로그인 실행 결과

enum AuthOutcome: Equatable {
    case authenticated(session: AuthSession, isNewUser: Bool) // 로그인이 완료되어 세션이 발급된 상태
    case emailVerificationRequired(email: String) // 계정은 생성되었지만, 이메일 인증을 해야 로그인 완료됨
}
