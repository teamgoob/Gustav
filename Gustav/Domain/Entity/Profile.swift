//
//  Profile.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - 사용자 프로필 정보
struct Profile: Equatable {
    let id: UUID        // 사용자 ID
    let displayName: String?    // 사용자 이름
    
    // 이메일 가리기 회원가입/로그인 시 유저확인용
    let email: String?
    let isPrivateEmail: Bool // 이메일 가리기인지 아닌지 구분용
    
    let createdAt: Date // 계정 생성일
    let updatedAt: Date // 사용자 이름 업데이트 시 기준
    
    // 프로필 이미지 URL
    let profileImageUrl: String?
}
