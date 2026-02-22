//
//  AuthSupabase.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation
import Supabase

// AuthDataSourceProtocol을 구현한 Supabase 기반 Auth DataSource
// 역할: Supabase SDK(auth)를 직접 호출해서
//  - 세션 복구/갱신
//  - Apple idToken 로그인
//  - 로그아웃
//  - 현재 유저 조회
// 를 수행하고, 실패 시 Error를 RepositoryError로 "파싱"해서 반환한다.
final class AuthSupabase: AuthDataSourceProtocol {

    // Supabase SDK에서 제공하는 클라이언트.
    // 이 객체를 통해 client.auth.xxx 형태로 인증 관련 API 호출을 한다.
    private let client: SupabaseClient

    // DI(의존성 주입): 외부에서 만든 SupabaseClient를 받아서 사용한다.
    // (각 DataSource가 client를 새로 만들지 않고 주입받는 게 테스트/설정 관리에 유리)
    init(client: SupabaseClient) {
        self.client = client
    }

    // 로컬에 저장된 AuthSession(accessToken/refreshToken)을 기반으로
    // Supabase 세션을 복구하거나(refresh) 갱신한다.
    func restoreOrRefreshSession(from local: AuthSession) async -> RepositoryResult<AuthSession> {
        do {
            // Supabase SDK 2.5.1 기준: setSession(accessToken, refreshToken) -> Session
            // 내부적으로 accessToken 만료 여부를 보고,
            //  - 만료됐으면 refreshToken으로 refreshSession 호출
            //  - 안 만료됐으면 user(jwt:)로 유저 정보 구성한 뒤 sessionManager 업데이트까지 수행한다.
            let session = try await client.auth.setSession(
                accessToken: local.accessToken,
                refreshToken: local.refreshToken
            )

            // SDK Session -> 우리 앱의 AuthSession(Entity/Model)로 변환
            return .success(Self.mapSession(session))
        } catch {
            // Supabase가 던진 원시 Error를 RepositoryError로 분류(파싱)해서 반환
            return .failure(Self.mapError(error))
        }
    }

    // Apple 로그인에서 획득한 idToken + nonce를 Supabase에 전달해 로그인(세션 생성)
    func signInWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthSession> {
        do {
            // OpenID Connect 기반 provider 로그인
            // provider: .apple, idToken/nonce 포함
            // 성공 시 Supabase Session을 반환한다(2.5.1 기준).
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )

            // SDK Session -> AuthSession로 매핑
            return .success(Self.mapSession(session))
        } catch {
            // Error -> RepositoryError로 파싱
            return .failure(Self.mapError(error))
        }
    }

    // Supabase 로그아웃(세션 정리)
    func signOut() async -> RepositoryResult<Void> {
        do {
            // Supabase SDK 로그아웃
            try await client.auth.signOut()
            return .success(())
        } catch {
            // Error -> RepositoryError로 파싱
            return .failure(Self.mapError(error))
        }
    }

    // 현재 로그인된 유저의 id를 가져온다.
    func currentUserId() async -> RepositoryResult<UUID> {
        do {
            // Supabase SDK: 현재 유저 정보 조회
            let user = try await client.auth.user()
            return .success(user.id)
        } catch {
            // 원시 Error -> RepositoryError로 파싱
            return .failure(Self.mapError(error))
        }
    }

    func signUpWithEmail(email: String, password: String) async -> RepositoryResult<EmailSignUpOutcome> {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            let session = response.session.map(Self.mapSession)
            let requiresEmailVerification = (session == nil)
            return .success(
                EmailSignUpOutcome(
                    session: session,
                    email: email,
                    requiresEmailVerification: requiresEmailVerification
                )
            )
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthSession> {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            return .success(Self.mapSession(session))
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // 서버 RPC/Edge Function: 현재 사용자 삭제
    func withdrawCurrentUser() async -> RepositoryResult<Void> {
        do {
            try await client.rpc("delete_current_user").execute()
            return .success(())
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    
    
    
    
    
    
    // Supabase SDK의 Session 타입을
    // 앱 내부에서 쓰는 AuthSession 타입으로 변환하는 함수.
    private static func mapSession(_ session: Session) -> AuthSession {
        AuthSession(
            // Supabase 세션의 accessToken
            accessToken: session.accessToken,

            // Supabase 세션의 refreshToken
            refreshToken: session.refreshToken,

            // Supabase 세션의 유저 id(UUID)를 문자열로 변환해 저장
            // (AuthSession.userId가 String인 설계라서 uuidString)
            userId: session.user.id.uuidString,

            // Supabase Session.expiresAt은 UNIX timestamp(TimeInterval, 초)
            // 앱에서는 Date로 쓰고 싶으니 Date(timeIntervalSince1970:)로 변환
            expiresAt: Date(timeIntervalSince1970: session.expiresAt)
        )
    }

    // Supabase/네트워크/기타 원시 Error를 앱 표준 에러인 RepositoryError로 분류하는 파서.
    private static func mapError(_ error: Error) -> RepositoryError {

/* 1순위 : 확실한 에러 */
        
        // 이미 RepositoryError로 들어온 경우 그대로 반환해서 중복 파싱을 피한다.
        if let repositoryError = error as? RepositoryError {
            return repositoryError
        }

        // JSON 디코딩 실패는 명시적으로 분리
        // 예: 응답 JSON 구조가 예상과 달라 디코딩이 실패한 경우
        if error is DecodingError {
            return .decoding
        }

        // Error를 Objective-C 기반의 NSError형태로 변환해서 공통 속성을 꺼내 쓰기 위함
        // Swift에서 Error는 런타임에서 대부분 NSError로 자동 변환됨
        ///nsError.domain    - 에러 종류 영역 (예: NSURLErrorDomain)
        ///nsError.code        - 정수 코드
        ///nsError.userInfo   - 추가 정보 딕셔너리
        let nsError = error as NSError

/* 2순위 : 가능하면 상태 코드 뽑기 */
        
        // localizedDescription( : 에러를 사람이 읽을 수 있는 문자열로 바꾼 것 )을 소문자로 변환해서 특정 키워드 포함 여부로 대략적인 원인 분류에 사용한다.
        let message = (nsError.localizedDescription).lowercased()

        // 1) 네트워크 계열 :: 에러가 네트워크 문제인지 먼저 판별
        // 1-1) NSError domain이 NSURLErrorDomain이면 네트워크/연결 계열로 판단 :: 인터넷 끊김, 서버연결 실패, DNS 실패, 타임아웃 등
        if nsError.domain == NSURLErrorDomain {
            return .network
        }

        // 1-2) domain으로 못 잡는 경우 대비.
        // 문자열에 네트워크 관련 문구가 있으면 network로 처리
        if message.contains("network")
            || message.contains("timed out")
            || message.contains("offline")
            || message.contains("internet appears to be offline")
            || message.contains("could not connect") {
            return .network
        }

        // 2) 상태코드 기반
        // 에러가 HTTP 요청에서 온 것
        
        /// 상태코드 추출
        let statusCode = extractHTTPStatusCode(from: nsError, message: message)

        if let code = statusCode {
            switch code {

            case 400:
                /// 400(Bad Request)은 다양한 원인이 가능.
                /// 그중 nonce/id token/invalid grant(토큰 교환 실패) 같은 경우는 로그인 자격증명 문제로 보고 invalidCredentials로 분류한다.
                if message.contains("nonce") || message.contains("id token") || message.contains("invalid grant") {
                    return .invalidCredentials
                }
                return .unknown

            case 401:
                // 인증 실패/토큰 만료/권한 없는 접근
                // 여기선 일단 unauthorized로 분류(컨텍스트가 로그인이라면 invalidCredentials로 바꿀 수도 있음)
                return .unauthorized

            case 403:
                // 권한 거부(주로 RLS 차단, permission denied)
                return .forbidden

            case 404:
                // 리소스 없음 (예 - id의 row가 없다)
                return .notFound

            case 409:
                // 충돌(유니크 제약 위반 등)
                return .conflict

            default:
                // 그 외 status code는 아래 문구 기반 파싱으로 넘김
                break
            }
        }

/* 3순위 : 문자열 키워드로 추정 */
        
        // 3) 문구 기반(GoTrue/PostgREST 에러 문자열 대응)
        // status code를 못 얻었을 때, message의 키워드로 추정한다.

        // 3-1) 자격증명 문제 / 토큰 검증 문제 :: 로그인 실패
        // - invalid login credentials
        // - invalid grant
        // - jwt 관련
        // - id token/nonce 관련
        if message.contains("invalid login credentials")
            || message.contains("invalid credentials")
            || message.contains("invalid grant")
            || message.contains("jwt")
            || message.contains("id token")
            || message.contains("nonce") {
            return .invalidCredentials
        }

        // 3-2) 환경 설정 문제 :: 개발자가 설정을 잘못한 경우
        // - provider is not enabled(애플 provider 켜지지 않음)
        // - invalid api key/anon key/apikey(키/프로젝트 설정 문제)
        // - not configured
        if message.contains("provider is not enabled")
            || message.contains("provider disabled")
            || message.contains("not configured")
            || message.contains("invalid api key")
            || message.contains("anon key")
            || message.contains("apikey") {
            return .misconfigured
        }

        // 3-3) 권한/RLS 차단 관련 문구
        if message.contains("row level security")
            || message.contains("permission denied")
            || message.contains("forbidden") {
            return .forbidden
        }

        // 3-4) not found 문구
        if message.contains("not found") {
            return .notFound
        }

        // 3-5) 중복/충돌 관련 문구
        if message.contains("duplicate")
            || message.contains("already exists")
            || message.contains("conflict") {
            return .conflict
        }

        // 위 규칙 어디에도 안 걸리면 알 수 없는 에러
        return .unknown
    }

    // NSError와 message에서 HTTP status code를 뽑아내는 보조 함수
    private static func extractHTTPStatusCode(from error: NSError, message: String) -> Int? {

        // 1) userInfo에 statusCode/status가 담기는 케이스
        // 라이브러리(HTTPClient)가 이렇게 넣는 경우가 있어서 우선 시도
        if let code = error.userInfo["statusCode"] as? Int {
            return code
        }
        if let code = error.userInfo["status"] as? Int {
            return code
        }

        // 2) 메시지 문자열에서 "status code: 401" 같은 패턴을 정규식으로 추출
        // pattern: "status code" 다음에 : 또는 = 있을 수도 있고 공백도 있을 수 있음.
        let pattern = #"status code[:=]?\s*(\d{3})"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: message,
                                           range: NSRange(message.startIndex..., in: message)),
              let range = Range(match.range(at: 1), in: message) else {
            return nil
        }

        // 추출된 3자리 숫자를 Int로 변환해 반환
        return Int(message[range])
    }
}
