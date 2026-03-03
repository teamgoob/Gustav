//
//  EmailSignUpOutcomeDTO.swift
//  Gustav
//
//  Created by kaeun on 2/27/26.
//

// Supabase 이메일 가입 API의 응답 형태

struct EmailSignUpOutcomeDTO {
    let session: AuthDTO?
    let email: String
    let requiresEmailVerification: Bool
}

//DomainConvertible로 만들지 말고 Repository에서 AuthOutcome로 조립
//DataSource → Repository 사이에서 사용
