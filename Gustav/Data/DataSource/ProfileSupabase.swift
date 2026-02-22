//
//  ProfileSupabase.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation
import Supabase // SupabaseClient, AnyJSON, 쿼리 빌더(from/select/update/insert)

final class ProfileSupabase: ProfileDataSourceProtocol {
    
    private let client: SupabaseClient // Supabase SDK의 핵심 클라이언트(네트워크 호출 주체). DI로 주입받아 사용
    private let table = "profiles" // 접근할 테이블의 이름
    
    // ISO8601 문자열 변환기. 매 호출마다 새로 만들면 비용이 커서 static으로 재사용
    private static let iso = ISO8601DateFormatter()
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    // 현재 시각 ISO 문자열 생성
    /// updateUserName, bootstrapAfterAppleAuth에서 updated_at / created_at 을 채울 때 사용
    private func nowString() -> String {
        // 현재 Date()를 ISO8601 문자열로 변환(예: 2026-02-23T12:34:56Z)
        Self.iso.string(from: Date())
    }
    
    // 특정 유저의 프로필 1건 조회(DataSource 책임)
    // - UseCase/Repository가 프로필이 있는지 확인하거나 화면에서 프로필을 보여줄 때 호출될 수 있음
    // - 반환: 성공이면 ProfileRecord(= DB row DTO), 실패면 RepositoryError
    func fetchProfile(userId: UUID) async -> RepositoryResult<ProfileRecord> {
        do { // 네트워크 호출은 실패할 수 있으므로 do/catch로 감싼다
            let rows: [ProfileRecord] = try await client // select 결과를 배열로 받기 위해 타입을 [ProfileRecord]로 지정
                .from(table)                             // "profiles" 테이블을 대상으로 쿼리를 시작
                .select()                                // SELECT * (필요하면 컬럼 지정 가능)
                .eq("id", value: userId)                 // WHERE id = userId (Supabase에서 보통 users.id와 profiles.id를 동일하게 씀)
                .limit(1)                                // 최대 1개만 가져오기(단건 조회)
                .execute()                               // 실제 네트워크 요청 실행
                .value                                   // 응답 body를 디코딩한 값(ProfileRecord 배열)
            
            guard let row = rows.first else {            // 조회 결과가 비어있으면
                return .failure(.notFound)               // "프로필이 없다"를 명시적으로 notFound로 반환(bootstrap에서 이걸 보고 insert 함)
            }
            return .success(row)                         // 결과가 있으면 첫 번째 row를 성공으로 반환
        } catch {                                        // Supabase SDK/네트워크/디코딩 등 모든 에러가 여기로 옴
            return .failure(mapError(error))             // 원시 Error를 RepositoryError로 파싱(분류)해서 반환
        }
    }
    
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
    
    func bootstrapAfterAppleAuth(
        userId: UUID,                                    // 현재 로그인된 userId(보통 auth.users.id)
        email: String?,                                  // 애플에서 내려온 email(첫 로그인 이후 nil일 수 있음)
        fullName: String?                                // 애플에서 내려온 fullName(첫 로그인 이후 nil일 수 있음)
    ) async -> RepositoryResult<Bool> {
        // Bool 의미: true=신규 생성됨, false=기존 프로필
        // 이 함수는 애플 로그인 성공 후 우리 앱 profiles row를 보장하는 용도
        // - 프로필이 없으면 생성(insert) → true
        // - 프로필이 있으면 비어있는 필드만 보완(update) → false
        
        do {
            let existing = await fetchProfile(userId: userId) // 우선 해당 userId의 profiles row가 존재하는지 조회
            
            // 프로필이 없는 경우 → 신규 생성
            switch existing {                                // fetchProfile의 결과(성공/실패)에 따라 분기
            case .failure(let e) where e == .notFound:        // 조회 실패인데 notFound라면 "프로필이 없음"을 의미
                
                let now = nowString()                         // created_at/updated_at에 같은 시각을 넣기 위해 한번만 계산
                
                let payload: [String: AnyJSON] = [            // insert할 row의 컬럼/값을 구성
                    "id": AnyJSON.string(userId.uuidString),  // profiles.id에 userId를 넣음(스키마가 UUID면 서버에서 캐스팅됨/또는 String 컬럼일 수도)
                    "name": fullName.map(AnyJSON.string) ?? .null, // fullName이 있으면 넣고 없으면 null 저장
                    "email": email.map(AnyJSON.string) ?? .null,   // email이 있으면 넣고 없으면 null 저장
                    "is_private_email": .bool(isPrivateRelay(email)), // email이 privaterelay면 true 저장(애플 이메일 가리기 감지)
                    "created_at": .string(now),               // 생성 시각(서버에서 자동 처리하면 생략 가능하지만 현재는 앱에서 넣는 설계)
                    "updated_at": .string(now)                // 초기 생성 시 updated_at도 created_at과 동일하게 설정
                ]
                
                try await client
                    .from(table)                          // profiles 테이블
                    .insert(payload)                      // INSERT INTO profiles (...) VALUES (...)
                    .execute()                            // 네트워크 요청 실행
                
                return .success(true)                     // 신규 생성했으므로 true 반환
                
            // 다른 에러는 그대로 전달
            case .failure(let e):
                return .failure(e)
                
                // 기존 프로필 존재
            case .success(let profile):
                
                let now = nowString()
                
                // 이름이 비어있고 fullName이 있으면 업데이트
                if let fullName, !fullName.isEmpty, (profile.name ?? "").isEmpty {
                    
                    let payload: [String: AnyJSON] = [
                        "name": .string(fullName),
                        "updated_at": .string(now)
                    ]
                    
                    try await client
                        .from(table)
                        .update(payload)
                        .eq("id", value: userId)
                        .execute()
                    
                }
                
                // 이메일이 비어있고 email이 있으면 업데이트
                if let email, !email.isEmpty, (profile.email ?? "").isEmpty {
                    
                    let payload: [String: AnyJSON] = [
                        "email": .string(email),
                        "is_private_email": .bool(isPrivateRelay(email)),
                        "updated_at": .string(now)
                    ]
                    
                    try await client
                        .from(table)
                        .update(payload)
                        .eq("id", value: userId)
                        .execute()
                    
                }
                
                return .success(false)
                
            }
        } catch {
            return .failure(mapError(error))
        }
    }
    
    private func isPrivateRelay(_ email: String?) -> Bool {    // 애플 “이메일 가리기” 사용 여부 추정 함수
        guard let email else { return false }                  // email이 없으면(=nil) private relay 판단 불가 → false
        return email.lowercased().hasSuffix("privaterelay.appleid.com") // 애플 relay 도메인으로 끝나면 true
        // 어디에 쓰임? bootstrapAfterAppleAuth에서 is_private_email 컬럼 값 계산에 사용
    }

    private func mapError(_ error: Error) -> RepositoryError { // Supabase/네트워크/기타 원시 Error를 RepositoryError로 분류
        if let e = error as? RepositoryError { return e }      // 이미 RepositoryError면 그대로 사용(중복 변환 방지)
        if error is DecodingError { return .decoding }         // 디코딩 에러는 decoding으로 분리(응답 구조 문제)
        return .unknown                                        // 그 외는 unknown 처리
    }
}
