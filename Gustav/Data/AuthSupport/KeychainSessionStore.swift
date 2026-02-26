//
//  KeychainSessionStore.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//
import Foundation
import Security

/// KeychainSessionStore의 역할
/// - AuthDTO(세션)를 기기 내부 Keychain에 저장/읽기/삭제 한다.
///
/// 왜 Keychain?
/// - accessToken/refreshToken 같은 로그인 토큰은 민감정보라서
///   UserDefaults 같은 곳에 저장하면 보안상 위험합니다.
/// - Keychain은 iOS가 제공하는 "비밀번호/토큰 저장소"라서 안전합니다.
final class KeychainSessionStore: SessionStore {

    /// Keychain에서 항목을 구분하기 위한 값(보통 앱 번들ID 사용)
    /// - 같은 폰에서 다른 앱과 섞이지 않게 구분하는 역할
    private let service: String

    /// Keychain에서 "이 항목의 이름" 같은 역할
    /// - 우리는 로그인 세션 하나만 저장하므로 기본값 "auth_session"으로 충분
    private let account: String

    /// 생성자
    /// - service/account는 Keychain에 저장할 위치/이름 같은 개념입니다.
    init(
        service: String = Bundle.main.bundleIdentifier ?? "AppService",
        account: String = "auth_session"
    ) {
        self.service = service
        self.account = account
    }

    // MARK: - 세션 읽기(load)

    /// Keychain에서 세션을 읽어옵니다.
    /// - 세션이 없으면 nil (아직 로그인 안 했거나 로그아웃 한 경우)
    /// - 세션이 있으면 AuthDTO로 복원해서 반환
    func load() throws -> AuthDTO? {
        do {
            // 1) Keychain에서 raw data 읽기
            guard let data = try readKeychain() else {
                // 저장된 값이 없으면 "비로그인 상태"로 보면 됨
                return nil
            }

            // 2) Data(JSON)를 AuthDTO로 디코딩(복원)
            return try JSONDecoder().decode(AuthDTO.self, from: data)

        } catch is DecodingError {
            // Keychain에 저장된 데이터가 깨졌거나(구조 변경, 저장 오류 등)
            // JSON 해석이 실패했을 때
            throw RepositoryError.decoding

        } catch let e as RepositoryError {
            // 이미 RepositoryError로 던진 에러면 그대로 전달
            throw e

        } catch {
            // Keychain API 실패 같은 기타 에러는 unknown으로 통일
            throw RepositoryError.unknown
        }
    }

    // MARK: - 세션 저장(save)

    /// 세션을 Keychain에 저장합니다.
    /// - 로그인 성공 후 "자동 로그인"을 위해 호출합니다.
    /// - 이미 값이 있으면 덮어쓰기(upsert) 됩니다.
    func save(_ session: AuthDTO) throws {
        do {
            // 1) AuthDTO를 JSON Data로 변환
            let data = try JSONEncoder().encode(session)

            // 2) Keychain에 저장(있으면 덮어쓰기)
            try upsertKeychain(data: data)

        } catch let e as RepositoryError {
            throw e
        } catch {
            throw RepositoryError.unknown
        }
    }

    // MARK: - 세션 삭제(clear)

    /// 세션을 Keychain에서 삭제합니다.
    /// - 로그아웃/회원탈퇴 성공 후 호출합니다.
    func clear() throws {
        do {
            try deleteKeychain()
        } catch let e as RepositoryError {
            throw e
        } catch {
            throw RepositoryError.unknown
        }
    }
}

// MARK: - Keychain 내부 구현(실제 저장/조회/삭제 코드)
private extension KeychainSessionStore {

    /// Keychain에서 데이터 읽기
    /// - query: 어떤 항목을 찾을지 조건(service/account) 지정
    /// - SecItemCopyMatching: 해당 조건에 맞는 데이터를 찾아줌
    func readKeychain() throws -> Data? {

        // Keychain 검색 조건(query)
        let query: [String: Any] = [
            // 어떤 종류의 Keychain 항목인지 (여기서는 "일반 비밀번호" 타입)
            kSecClass as String: kSecClassGenericPassword,

            // 우리 앱의 저장영역(service)
            kSecAttrService as String: service,

            // 항목 이름(account)
            kSecAttrAccount as String: account,

            // 실제 데이터(Data)를 돌려달라
            kSecReturnData as String: true,

            // 하나만 찾기
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?

        // 실제 조회 실행
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        // Keychain에 값이 없으면 "nil 반환" (에러 아님)
        if status == errSecItemNotFound {
            return nil
        }

        // 그 외 상태는 실패로 간주
        guard status == errSecSuccess else {
            throw RepositoryError.unknown
        }

        return item as? Data
    }

    /// Keychain에 데이터 저장(있으면 덮어쓰기)
    /// - 초보 단계에서는 "삭제 후 추가"가 구현이 단순합니다.
    func upsertKeychain(data: Data) throws {

        // 1) 기존 값이 있으면 삭제 (없으면 그냥 무시)
        // try?를 쓰는 이유: 없으면 errSecItemNotFound인데, 그건 정상 케이스라서 무시해도 됨
        try? deleteKeychain()

        // 2) 새로 추가할 조건 + 데이터
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,

            // 실제 저장할 데이터
            kSecValueData as String: data
        ]

        // Keychain에 저장
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw RepositoryError.unknown
        }
    }

    /// Keychain에서 데이터 삭제
    func deleteKeychain() throws {

        // 삭제할 항목을 지정하는 query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        // 이미 없으면 삭제 성공으로 취급
        if status == errSecItemNotFound { return }

        guard status == errSecSuccess else {
            throw RepositoryError.unknown
        }
    }
}
