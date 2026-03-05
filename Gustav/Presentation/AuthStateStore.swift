//
//  AuthStateStore.swift
//  Gustav
//
//  Created by kaeun on 3/2/26.
//

import Combine
import Foundation

// 앱 전역의 인증 상태(AuthState)를 관리하는 단일 저장소
final class AuthStateStore {
    static let shared = AuthStateStore()

    let subject = CurrentValueSubject<AuthState, Never>(.unknown)

    private init() {}
}
