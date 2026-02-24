//
//  KeychainSessionStore.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//
import Foundation
import Security // Keychain API 사용을 위해 필요

// 앱 재실행 후 자동 로그인 - 세션 영속화

final class KeychainSessionStore: SessionStore { // SessionStore 프로토콜 구현체(구체 저장소)
    private let service: String                  // Keychain 서비스 식별자(보통 bundle id)
    private let account = "auth_session"         // 같은 서비스 내에서 세션 엔트리 키 역할

    init(service: String) {                      // 외부에서 service 주입(DI 가능)
        self.service = service                   // 전달받은 service 저장
    }

    // 만료 갱신 판단
    func load() throws -> AuthSession? {         // Keychain에서 세션 읽기
        var query: [String: Any] = baseQuery     // 공통 쿼리(service/account/class) 복사
        query[kSecReturnData as String] = true   // 매칭 결과의 실제 Data를 반환받도록 설정
        query[kSecMatchLimit as String] = kSecMatchLimitOne // 하나만 읽음

        var item: CFTypeRef?                     // Keychain 조회 결과
        // query 조건으로 Keychain을 검색하고, 찾은 값을 item에 채워 넣으라는 호출
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        // 저장된 세션 없음(정상 시나리오)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            // 조회 실패/타입 불일치
            throw SessionError.loadFailed         // load 실패 에러
        }

        // Keychain에서 꺼낸 data(바이너리/JSON 형태)를 앱에서 쓰는 AuthSession 객체로 변환 (역직렬화)
        return try JSONDecoder().decode(AuthSession.self, from: data)
    }

    // 세션 저장 또는 갱신
    func save(_ session: AuthSession) throws {
        let data = try JSONEncoder().encode(session) // AuthSession -> Data로 변환(직렬화)
        var attributes = baseQuery               // SecItemAdd(새로 저장)용 기본 속성(service/account/class)
        attributes[kSecValueData as String] = data // 저장할 실제 데이터 추가

        let status = SecItemAdd(attributes as CFDictionary, nil) // 신규 저장 시도
        if status == errSecDuplicateItem {       // 이미 있으면
            let updateStatus = SecItemUpdate(    // 기존 값 업데이트
                baseQuery as CFDictionary,       // 어떤 항목을 업데이트할지(키)
                [kSecValueData as String: data] as CFDictionary // 새 데이터
            )
            guard updateStatus == errSecSuccess else { throw SessionError.saveFailed } // 갱신 실패
            return                               // 갱신 성공 시 종료
        }

        guard status == errSecSuccess else { throw SessionError.saveFailed } // 신규 저장 실패
    }

    // 세션 삭제(로그아웃/탈퇴)
    func clear() throws {
        let status = SecItemDelete(baseQuery as CFDictionary) // service+account 항목 삭제
        guard status == errSecSuccess || status == errSecItemNotFound else { // 없으면 성공으로 간주
            throw SessionError.clearFailed       // 실제 삭제 실패만 에러
        }
    }

    //l oad/save/clear 모두 이 3개 조합으로 같은 레코드 1개를 대상으로 동작하게 만드는 것
    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword, // 일반 비밀번호 타입으로 저장
            kSecAttrService as String: service,            // 앱/모듈 단위 구분
            kSecAttrAccount as String: account             // 항목 이름(여기서는 auth_session)
        ]
    }
}
