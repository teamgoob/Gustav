//
//  SessionStore.swift
//  Gustav
//
//  Created by kaeun on 2/10/26.
//

import Foundation

// MARK: - SessionStore
//AuthSession을 기기 로컬에 저장/조회/삭제하는 저장소 역할
//다시 로그인하지 않게 하려면 세션을 기기에 저장해둬야함 = 자동로그인
protocol SessionStore {
    func load() throws -> AuthDTO?          // 세션 읽어오기
    func save(_ session: AuthDTO) throws    // 세션 저장/갱신
    func clear() throws                         // 세션 삭세
}

//구현
/// AuthSession을 Data로 인코딩함.
/// Keychain에 넣고/빼고/지우는 것
