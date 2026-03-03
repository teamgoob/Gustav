//
//  AuthState.swift
//  Gustav
//
//  Created by kaeun on 3/2/26.
//

import Foundation

// 코디네이터 패턴을 화면 전환을 위해서 구독할 상태값.
enum AuthState: Equatable {
    case unknown              // 앱 시작 직후 아직 판단 전
    case signedOut            // 비로그인
    case signedIn(userId: UUID) // 로그인
}
