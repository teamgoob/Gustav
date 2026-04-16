//
//  ProfileSupabase.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation
import Supabase // SupabaseClient, AnyJSON, 쿼리 빌더(from/select/update/insert)


/// ProfileSupabase의 역할(=DataSource)
///
/// ✅ 하는 일 (딱 3가지)
/// 1) profiles 테이블에서 프로필을 조회한다 (fetchProfile)
/// 2) 프로필의 이름을 수정한다 (updateUserName)
/// 3) (로그인 직후) 프로필이 없으면 만들고, 있으면 비어있는 값만 채운다 (bootstrapAfterAppleAuth / upsertProfile)
///
/// ✅ 여기서 "직접" 하는 것
/// - Supabase SDK로 네트워크 요청을 보낸다 (select/insert/update)
/// - DB에서 내려오는 데이터를 DTO(ProfileDTO)로 디코딩한다
/// - 실패하면 에러를 RepositoryError로 통일해서 반환한다
///
/// ❌ 여기서는 하지 않는 것
/// - Domain Entity(Profile)로 변환 (Repository가 함)
/// - "로그인/온보딩 흐름 전체" 조립 (UseCase가 함)
/// - 화면(UI) 업데이트 (Presentation/ViewModel이 함)



final class ProfileSupabase: ProfileDataSourceProtocol {
    
    
    private let client: SupabaseClient // Supabase SDK의 핵심 클라이언트(네트워크 호출 주체). DI로 주입받아 사용
    private let table = "profiles" // 접근할 테이블의 이름
    
    // ISO8601 문자열 변환기. 매 호출마다 새로 만들면 비용이 커서 static으로 재사용
    /// - DB에 timestamp를 String 형태로 저장할 때 사용한다.
    private static let iso = ISO8601DateFormatter()
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    /// 현재 시각을 ISO8601 문자열로 만들어서 반환
    /// 예) "2026-03-02T12:34:56Z"
    private func nowString() -> String {
        Self.iso.string(from: Date())
    }
    
    // MARK: - 프로필 단건 조회

    /// 특정 userId에 해당하는 프로필을 1건 조회한다.
    ///
    /// 성공:
    /// - ProfileDTO 반환
    ///
    /// 실패:
    /// - notFound: 해당 userId의 row가 없음
    /// - network/decoding 등 다른 RepositoryError
    func fetchProfile(userId: UUID) async -> RepositoryResult<ProfileDTO> {
        do { // 네트워크 호출은 실패할 수 있으므로 do/catch로 감싼다
            // SELECT * FROM profiles WHERE id = userId LIMIT 1
            let rows: [ProfileDTO] = try await client // select 결과를 배열로 받기 위해 타입을 [ProfileDTO]로 지정
                .from(table)                             // "profiles" 테이블을 대상으로 쿼리를 시작
                .select()                                // SELECT * (필요하면 컬럼 지정 가능)
                .eq("id", value: userId)                 // WHERE id = userId (Supabase에서 보통 users.id와 profiles.id를 동일하게 씀)
                .limit(1)                                // 최대 1개만 가져오기(단건 조회)
                .execute()                               // 실제 네트워크 요청 실행
                .value                                   // 응답 body를 디코딩한 값(ProfileDTO 배열)
            
            guard let row = rows.first else {            // 조회 결과가 비어있으면
                return .failure(.notFound)               // "프로필이 없다"를 명시적으로 notFound로 반환(bootstrap에서 이걸 보고 insert 함)
            }
            return .success(row)                         // 결과가 있으면 첫 번째 row를 성공으로 반환
        } catch {                                        // Supabase SDK/네트워크/디코딩 등 모든 에러가 여기로 옴
            return .failure(mapError(error))             // 원시 Error를 RepositoryError로 파싱(분류)해서 반환
        }
    }
    
    // MARK: - 이름 수정
    
    /// 프로필의 name 컬럼만 수정한다.
    ///
    /// - 보통 "프로필 수정 화면"에서 사용된다.
    /// - updated_at도 함께 갱신한다.
    func updateUserName(userId: UUID, name: String) async -> RepositoryResult<Void> {
        // 특정 유저의 name만 변경하는 기능
        // - UseCase(ProfileUseCase.updateUserName) → Repository → DataSource로 내려오는 호출로 보통 사용
        do {
            let payload: [String: AnyJSON] = [           // Supabase update에 들어갈 body(payload). AnyJSON으로 타입을 안전하게 표현
                "name": .string(name),                   // name 컬럼을 문자열로 업데이트
                "updated_at": .string(nowString())       // updated_at도 함께 갱신(서버에서 자동 처리 안 한다면 앱에서 넣어줌)
            ]
            
            try await client
                .from(table)                             // profiles 테이블 대상
                .update(payload)                         // UPDATE profiles SET ... payload ...
                .eq("id", value: userId)                 // WHERE id = userId
                .execute()                               // 네트워크 요청 실행(성공/실패만 필요하므로 value는 사용하지 않음)
            
            return .success(())                          // 성공 시 Void 성공 반환
        } catch {
            return .failure(mapError(error))             // 실패 시 에러 파싱해서 반환
        }
    }
    
    
    // MARK: - 로그인 직후 프로필 보장 (insert or update)

    /// upsertProfile
    ///
    /// 🎯 목적:
    /// - 로그인 직후, profiles 테이블에 반드시 row가 존재하도록 보장한다.
    ///
    /// 동작:
    /// 1) 먼저 fetchProfile로 존재 여부 확인
    /// 2) 없으면 insert
    /// 3) 있으면 "비어있는 값만" update
    ///
    /// 반환:
    /// - 성공 시 Void
    /// - 실패 시 RepositoryError
    
    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> RepositoryResult<Void> {

        do {
            // 먼저 기존 프로필이 있는지 조회
            let existing = await fetchProfile(userId: userId)

            switch existing {

            // 프로필이 없으면 → insert
            case .failure(let e) where e == .notFound:

                let now = nowString()

                let payload: [String: AnyJSON] = [
                    "id": .string(userId.uuidString),
                    "name": displayName.map(AnyJSON.string) ?? .null,
                    "email": email.map(AnyJSON.string) ?? .null,
                    "is_private_email": .bool(isPrivateRelay(email)),
                    "created_at": .string(now),
                    "updated_at": .string(now),
                    "profile_image_url": .null
                ]

                try await client
                    .from(table)
                    .insert(payload)
                    .execute()

                return .success(())

            // 조회 중 다른 에러면 그대로 반환
            case .failure(let e):
                return .failure(e)

            // 기존 프로필이 있으면 → 비어있는 값만 update
            case .success(let profile):

                var payload: [String: AnyJSON] = [:]
                let now = nowString()

                // 기존 name이 비어있고 새 displayName이 있으면 채움
                if let displayName,
                   !displayName.isEmpty,
                   (profile.name ?? "").isEmpty {
                    payload["name"] = .string(displayName)
                }

                // 기존 email이 비어있고 새 email이 있으면 채움
                if let email,
                   !email.isEmpty,
                   (profile.email ?? "").isEmpty {
                    payload["email"] = .string(email)
                    payload["is_private_email"] = .bool(isPrivateRelay(email))
                }

                // 바뀐 게 있으면 update 실행
                if payload.isEmpty == false {
                    payload["updated_at"] = .string(now)

                    try await client
                        .from(table)
                        .update(payload)
                        .eq("id", value: userId)
                        .execute()
                }

                return .success(())
            }

        } catch {
            return .failure(mapError(error))
        }
    }
    


    // MARK: - Private Relay 판별

    /// 애플 "이메일 가리기" 기능을 사용했는지 판별한다.
    ///
    /// - privaterelay.appleid.com 도메인으로 끝나면 true
    /// - 그 외는 false
    ///
    /// 이 값을 DB에 저장해두면
    /// - 실제 이메일인지
    /// - 애플 relay 이메일인지
    /// 나중에 구분할 수 있다.
    
    private func isPrivateRelay(_ email: String?) -> Bool {    // 애플 “이메일 가리기” 사용 여부 추정 함수
        guard let email else { return false }                  // email이 없으면(=nil) private relay 판단 불가 → false
        return email.lowercased().hasSuffix("privaterelay.appleid.com") // 애플 relay 도메인으로 끝나면 true
        // 어디에 쓰임? bootstrapAfterAppleAuth에서 is_private_email 컬럼 값 계산에 사용
    }
    
    
    // MARK: - Error 통일 처리

    /// 다양한 Error를 RepositoryError로 통일한다.
    ///
    /// 이유:
    /// - DataSource는 "에러 표준화" 책임이 있다.
    /// - Repository/UseCase는 RepositoryError만 알면 되도록 만들기 위함.
    private func mapError(_ error: Error) -> RepositoryError {
        if let e = error as? RepositoryError { return e }
        if error is DecodingError { return .decoding }

        if let urlError = error as? URLError { return urlError.mapToRepositoryError() }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain { return .network }

        return .unknown
    }}
