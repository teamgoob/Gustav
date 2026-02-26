import Foundation
import Supabase

/// Supabase Auth를 "직접 호출"하는 DataSource 구현체입니다.
///
/// ✅ 여기서 하는 일
/// - Supabase SDK(auth) 호출
/// - 성공하면 DTO(AuthDTO, EmailSignUpOutcomeDTO)로 반환
/// - 실패하면 mapError로 RepositoryError로 통일해서 반환
///
/// ❌ 여기서 안 하는 일
/// - Keychain 저장/복구(SessionStore)
/// - "자동로그인 전체 흐름" 조립(Repository/UseCase 책임)

final class AuthSupabase: AuthDataSourceProtocol {

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Apple 로그인 (idToken + nonce -> Supabase 세션 생성)
    func signInWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthDTO> {
        do {
            // Apple에서 받은 idToken, nonce(원문)를 Supabase에 전달하면
            // Supabase가 accessToken/refreshToken이 포함된 "세션"을 만들어 줍니다.
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )

            // Supabase Session -> 우리 앱 DTO(AuthDTO)로 변환
            return .success(Self.mapAuthDTO(session, provider: "apple"))
        } catch {
            // Supabase가 던진 Error를 "우리 앱 규격(RepositoryError)"로 변환
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 이메일 회원가입
    func signUpWithEmail(email: String, password: String) async -> RepositoryResult<EmailSignUpOutcomeDTO> {
        do {
            // signUp 결과로 session이 "있을 수도 있고 없을 수도" 있습니다.
            // - 세션이 있으면: 가입과 동시에 로그인 완료
            // - 세션이 nil이면: 이메일 인증 필요(verification)
            let response = try await client.auth.signUp(email: email, password: password)

            let sessionDTO: AuthDTO? = response.session.map { session in
                Self.mapAuthDTO(session, provider: "email")
            }

            let requiresEmailVerification = (sessionDTO == nil)

            return .success(
                EmailSignUpOutcomeDTO(
                    session: sessionDTO,
                    email: email,
                    requiresEmailVerification: requiresEmailVerification
                )
            )
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 이메일 로그인
    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthDTO> {
        do {
            // 이메일/비밀번호가 맞으면 세션이 바로 만들어집니다.
            let session = try await client.auth.signIn(email: email, password: password)
            return .success(Self.mapAuthDTO(session, provider: "email"))
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 세션 갱신(Refresh)
    func refreshSession(refreshToken: String) async -> RepositoryResult<AuthDTO> {
        do {
            // ⚠️ Supabase Swift SDK 버전에 따라 refresh 함수 시그니처가 다를 수 있습니다.
            //
            // (1) 어떤 버전은 refreshSession()만 제공(내부 저장된 refreshToken 사용)
            // (2) 어떤 버전은 refreshToken을 인자로 받음
            //
            // ✅ 아래 한 줄만 너희 프로젝트의 Supabase SDK에 맞게 수정하면 됩니다.

            // 예시 A) refreshToken을 인자로 받는 버전인 경우:
            // let session = try await client.auth.refreshSession(refreshToken: refreshToken)

            // 예시 B) 인자 없이 갱신하는 버전인 경우:
            let session = try await client.auth.refreshSession()

            return .success(Self.mapAuthDTO(session, provider: "unknown"))
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 로그아웃
    func signOut() async -> RepositoryResult<Void> {
        do {
            // Supabase 서버/클라이언트 세션 정리
            try await client.auth.signOut()
            return .success(())
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 회원탈퇴(서버 RPC/Edge Function)
    func withdrawCurrentUser() async -> RepositoryResult<Void> {
        do {
            // Edge Function 호출 (auth.users 삭제)
            _ = try await client.functions.invoke("delete-user")
            return .success(())
        } catch {
            return .failure(Self.mapError(error))
        }
    }
    
}

// MARK: - 매핑(변환) 함수들
private extension AuthSupabase {

    /// Supabase의 Session 타입을 우리 앱의 AuthDTO로 바꿉니다.
    static func mapAuthDTO(_ session: Session, provider: String) -> AuthDTO {
        AuthDTO(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            userId: session.user.id,
            expiresAt: Date(timeIntervalSince1970: session.expiresAt),
            provider: provider
        )
    }

    /// Supabase / 네트워크 / 디코딩 등 다양한 Error를 RepositoryError로 통일합니다.
    static func mapError(_ error: Error) -> RepositoryError {

        // 1) 이미 RepositoryError면 그대로 사용(중복 변환 방지)
        if let e = error as? RepositoryError { return e }

        // 2) 디코딩 문제
        if error is DecodingError { return .decoding }

        // 3) 네트워크 문제(URLError / NSURLErrorDomain)
        if let urlError = error as? URLError { return urlError.mapToRepositoryError() }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain { return .network }

        // 4) 메시지 기반 추정(최후의 수단)
        let message = nsError.localizedDescription.lowercased()

        // 취소
        if message.contains("cancel") { return .cancelled }

        // 레이트 리밋
        if message.contains("rate limit") || message.contains("too many requests") || message.contains("429") {
            return .rateLimited
        }

        // 이메일 인증 필요(문구는 프로젝트/설정에 따라 다를 수 있음)
        if message.contains("email not confirmed")
            || message.contains("email not verified")
            || message.contains("confirm your email") {
            return .emailNotVerified
        }

        // 자격증명 문제(로그인 정보/토큰/nonce 문제)
        if message.contains("invalid login credentials")
            || message.contains("invalid credentials")
            || message.contains("invalid grant")
            || message.contains("jwt")
            || message.contains("id token")
            || message.contains("nonce") {
            return .invalidCredentials
        }

        // 설정 문제(Provider 미활성화, 키/URL 문제 등)
        if message.contains("provider is not enabled")
            || message.contains("provider disabled")
            || message.contains("not configured")
            || message.contains("invalid api key")
            || message.contains("anon key")
            || message.contains("apikey") {
            return .misconfigured
        }

        // 권한 문제(RLS)
        if message.contains("row level security")
            || message.contains("permission denied")
            || message.contains("forbidden") {
            return .forbidden
        }

        // 그 외
        return .unknown
    }
}
