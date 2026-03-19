
import Foundation
import Supabase


final class AuthSupabase: AuthDataSourceProtocol {

    private let client: SupabaseClient

    // provider 문자열 오타 방지용
    private enum ProviderString {
        static let apple = "apple"
        static let email = "email"
        static let unknown = "unknown"
    }

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - 세션 조회(검증 없이)
    /// SDK가 "현재 들고 있는 세션"을 그대로 가져옵니다.
    /// - 검증/리프레시를 하지 않습니다.
    func currentSession() async -> RepositoryResult<AuthDTO?> {
        guard let session = client.auth.currentSession else {
            return .failure(.sessionNotFound)
        }
        return .success(Self.mapAuthDTO(session, provider: ProviderString.unknown))
    }

    // MARK: - 세션 조회(검증 + 필요 시 refresh)
    /// SDK가 세션을 "검증"하고, 필요하면 refresh까지 수행한 결과를 가져옵니다.
    func validSession() async -> RepositoryResult<AuthDTO?> {
        do {
            let session: Session = try await client.auth.session
            return .success(Self.mapAuthDTO(session, provider: ProviderString.unknown))
        } catch {
            let repoError = Self.mapError(error)

            if repoError == .sessionNotFound || repoError == .unauthorized {
                return .failure(.sessionNotFound)
            }

            return .failure(repoError)
        }
    }

    // MARK: - Apple 로그인 (idToken + nonce -> Supabase 세션 생성)
    func authenticateWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthDTO> {
        print("=== authenticateWithApple called ===")
        print("idToken empty:", idToken.isEmpty)
        print("nonce empty:", nonce.isEmpty)
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )

            print("=== Supabase Apple sign in success ===")
            print("userId:", session.user.id)
            print("email:", session.user.email ?? "nil")
            print("createdAt:", session.user.createdAt)

            return .success(Self.mapAuthDTO(session, provider: ProviderString.apple))
        } catch {
            print("=== Supabase Apple sign in failed ===")
            print(error)
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 이메일 회원가입
    func signUpWithEmail(email: String, password: String) async -> RepositoryResult<EmailSignUpOutcomeDTO> {
        do {
            let response = try await client.auth.signUp(email: email, password: password)

            // 가입 응답에서 session은 있을 수도, 없을 수도 있습니다.
            // - session != nil : 가입과 동시에 로그인 완료
            // - session == nil : 이메일 인증 필요
            let sessionDTO: AuthDTO? = response.session.map {
                Self.mapAuthDTO($0, provider: ProviderString.email)
            }

            return .success(
                EmailSignUpOutcomeDTO(
                    session: sessionDTO,
                    email: email,
                    requiresEmailVerification: (sessionDTO == nil)
                )
            )
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 이메일 로그인
    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthDTO> {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            return .success(Self.mapAuthDTO(session, provider: ProviderString.email))
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 비밀번호 재설정 메일 발송
    func resetPassword(email: String) async -> RepositoryResult<Void> {
        do {
            try await client.auth.resetPasswordForEmail(email)
            return .success(())
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 로그아웃
    func signOut() async -> RepositoryResult<Void> {
        do {
            try await client.auth.signOut()
            return .success(())
        } catch {
            return .failure(Self.mapError(error))
        }
    }

    // MARK: - 회원탈퇴 (Edge Function)
    /// Edge Function을 호출해서 "현재 로그인 유저"를 삭제합니다.
    /// - 클라이언트는 service_role을 절대 가지면 안 되므로
    /// - 서버(Edge Function)에서 service_role로 auth.admin.deleteUser(...) 수행
    func withdrawCurrentUser() async -> RepositoryResult<Void> {
        do {
            _ = try await client.functions.invoke("delete-user")
            return .success(())
        } catch {
            return .failure(Self.mapError(error))
        }
    }
    
    // MARK: - 현재 유저 아이디
    func currentUserId() -> UUID? {
        client.auth.currentSession?.user.id
    }
}

// MARK: - Mapping / Error Parsing
private extension AuthSupabase {

    /// Supabase Session -> AuthDTO 변환
    static func mapAuthDTO(_ session: Session, provider: String) -> AuthDTO {
        // expiresAt이 Unix seconds인 경우가 대부분
        // 일부 버전/상황에서 옵셔널일 수 있다고 가정하고 방어적으로 처리
        let expires: Date? = {
            // session.expiresAt이 TimeInterval(Double) 타입인 경우가 많음
            // 만약 컴파일 에러가 나면, 해당 SDK 버전의 타입에 맞춰 아래 한 줄만 수정하면 됨.
            Date(timeIntervalSince1970: session.expiresAt)
        }()

        return AuthDTO(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            userId: session.user.id,
            expiresAt: expires,
            provider: provider
        )
    }

    /// 다양한 Error를 RepositoryError로 통일
    static func mapError(_ error: Error) -> RepositoryError {

        // 1) 이미 RepositoryError면 그대로
        if let e = error as? RepositoryError { return e }

        // 2) AppleAuthError가 섞여 들어오면 RepositoryError로 변환
        if let apple = error as? AppleAuthError { return apple.mapToRepositoryError() }

        // 3) 디코딩
        if error is DecodingError { return .decoding }

        // 4) 네트워크(URLError / NSURLErrorDomain)
        if let urlError = error as? URLError { return urlError.mapToRepositoryError() }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain { return .network }

        // 5) 메시지 기반(최후의 수단)
        let message = nsError.localizedDescription.lowercased()

        // 세션 없음
        if message.contains("session not found")
            || message.contains("no current session")
            || message.contains("not logged in") {
            return .sessionNotFound
        }

        // 취소
        if message.contains("cancel") { return .cancelled }

        // 레이트 리밋
        if message.contains("rate limit")
            || message.contains("too many requests")
            || message.contains("429") {
            return .rateLimited
        }

        // 이메일 인증 필요
        if message.contains("email not confirmed")
            || message.contains("email not verified")
            || message.contains("confirm your email") {
            return .emailNotVerified
        }
        
        // 이메일 중복(이미 가입된 계정)
        if message.contains("user already registered")
            || message.contains("already registered")
            || message.contains("email already")
            || message.contains("already exists")
            || message.contains("duplicate key value")
            || message.contains("email address already") {
            return .conflict
        }

        // 자격증명 문제(로그인 정보/토큰/nonce)
        if message.contains("invalid login credentials")
            || message.contains("invalid credentials")
            || message.contains("invalid grant")
            || message.contains("jwt")
            || message.contains("id token")
            || message.contains("nonce") {
            return .invalidCredentials
        }

        // 설정 문제
        if message.contains("provider is not enabled")
            || message.contains("provider disabled")
            || message.contains("not configured")
            || message.contains("invalid api key")
            || message.contains("anon key")
            || message.contains("apikey") {
            return .misconfigured
        }

        // 권한 문제(RLS 등)
        if message.contains("row level security")
            || message.contains("permission denied")
            || message.contains("forbidden") {
            return .forbidden
        }

        return .unknown
        

    }
    
}
