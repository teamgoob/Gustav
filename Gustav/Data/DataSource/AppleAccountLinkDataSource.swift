//
//  AppleAccountLinkDataSource.swift
//  Gustav
//
//  Created by kaeun on 3/27/26.
//

import Foundation
import Supabase

final class AppleAccountLinkDataSource: AppleAccountLinkDataSourceProtocol {
    private let client: SupabaseClient
    private let baseURL: URL
    private let urlSession: URLSession

    init(
        client: SupabaseClient,
        baseURL: URL,
        urlSession: URLSession = .shared
    ) {
        self.client = client
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    /// Apple 로그인 직후 authorizationCode를 서버에 전달하여
    /// Apple refresh token 저장에 필요한 연결 작업을 수행한다.
    func registerAppleAuthorizationCode(
        authorizationCode: String,
        identityToken: String
    ) async -> RepositoryResult<Void> {
        do {
            guard let accessToken = try currentAccessToken() else {
                return .failure(.sessionNotFound)
            }

            let url = endpointURL(pathComponents: ["apple-link"])

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let body = RegisterAppleAuthorizationCodeRequest(
                authorizationCode: authorizationCode,
                identityToken: identityToken
            )
            request.httpBody = try JSONEncoder().encode(body)

            let (_, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.network)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(mapStatusCode(httpResponse.statusCode))
            }

            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }

    /// 현재 로그인된 계정을 서버에서 삭제한다.
    /// 서버는 내부적으로 Apple revoke -> 도메인 데이터 삭제 -> Auth 유저 삭제를 수행한다.
    func withdrawCurrentAccount() async -> RepositoryResult<Void> {
        do {
            guard let accessToken = try currentAccessToken() else {
                return .failure(.sessionNotFound)
            }

            let url = endpointURL(pathComponents: ["account"])

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let (_, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.network)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(mapStatusCode(httpResponse.statusCode))
            }

            // 계정 삭제가 끝난 뒤에는 현재 기기의 로컬 세션도 비워서
            // stale session이 남지 않도록 한다.
            do {
                try await client.auth.signOut(scope: .local)
            } catch {
                return .success(())
            }

            return .success(())
        } catch {
            return .failure(mapError(error))
        }
    }
}

// MARK: - Private
private extension AppleAccountLinkDataSource {
    func endpointURL(pathComponents: [String]) -> URL {
        pathComponents.reduce(baseURL) { partialURL, component in
            partialURL.appendingPathComponent(component)
        }
    }

    func currentAccessToken() throws -> String? {
        guard let session = client.auth.currentSession else {
            return nil
        }
        return session.accessToken
    }

    func mapStatusCode(_ statusCode: Int) -> RepositoryError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 409:
            return .conflict
        case 429:
            return .rateLimited
        case 500...599:
            return .network
        default:
            return .unknown
        }
    }

    func mapError(_ error: Error) -> RepositoryError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                return .network
            default:
                return .unknown
            }
        }

        return .unknown
    }
}

// MARK: - Request DTO
private struct RegisterAppleAuthorizationCodeRequest: Encodable {
    let authorizationCode: String
    let identityToken: String
}
