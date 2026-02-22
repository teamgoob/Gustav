//
//  AppleSignInProvider.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation
import AuthenticationServices
import UIKit

// Apple SDK(콜백 기반)를 async/await 형태로 감싼 구현체.
// Apple SDK 상세를 몰라도 되게
final class AppleSignInProvider: NSObject, AppleAuthProviding {

    // withCheckedThrowingContinuation
    // 나중에 signIn()을 끝내기 위한 제어권
    // Apple 로그인 콜백(delegate)에서 성공/실패를 async 함수 결과로 되돌릴 때 사용.
    private var continuation: CheckedContinuation<AppleIDTokenResult, Error>?

    // Supabase 검증에 보낼 raw nonce를 잠시 보관.
    // Apple request에는 sha256(raw nonce)를 넣고, Supabase에는 raw nonce를 보내야 함.
    private var currentNonce: String?

    // Apple 로그인 시트를 어느 윈도우 위에 띄울지(프레젠테이션 앵커) 보관.
    // Apple 로그인 UI는 표시 기준 창이 필요해서 presentationAnchor(for:)에서 이 값을 반환해야 함.
    private var currentAnchor: ASPresentationAnchor?

    // 외부(UseCase/Repository)에서 호출하는 진입점.
    // "콜백 기반 Apple 로그인"을 "async throws -> AppleIDTokenResult"로 변환한 함수.
    func signIn() async throws -> AppleIDTokenResult {
        try await withCheckedThrowingContinuation { continuation in
            // UI 관련 API(윈도우 탐색, ASAuthorizationController)는 메인 스레드에서 처리해야 안전.
            Task { @MainActor in

                // 중복 로그인 방지: 이미 진행 중이면 즉시 에러.
                guard self.continuation == nil else {
                    continuation.resume(throwing: AppleAuthError.inProgress)
                    return
                }

                // 로그인 시트를 띄울 윈도우를 찾음.
                // 화면 띄울 창 없으면 로그인 자체를 시작하지 않는다
                guard let anchor = Self.findPresentationAnchor() else {
                    continuation.resume(throwing: AppleAuthError.missingPresentationAnchor)
                    return
                }

                // nonce 생성(원문 저장).
                let rawNonce = Nonce.randomString()
                self.currentNonce = rawNonce
                self.currentAnchor = anchor
                self.continuation = continuation // delegate 콜백에서 resume할 핸들 저장

                // Apple 로그인 요청 생성.
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email] // 최초 동의 시 전달될 수 있음
                request.nonce = Nonce.sha256(rawNonce) // Apple에는 해시 nonce 전달

                // 요청 실행 컨트롤러 구성.
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self // 성공/실패 콜백 수신, 로그인 결과(성공/실패)를 누구에게 알려줄지 지정
                controller.presentationContextProvider = self // 어느 window에 띄울지 제공
                controller.performRequests() // 실제 Apple 로그인 시작
            }
        }
    }

    // 공통 완료 처리: continuation 재개 + 임시 상태 정리.
    // MainActor를 붙인 이유:
    // 1) continuation/currentNonce/currentAnchor 상태를 한 스레드(메인)에서 일관되게 관리
    // 2) delegate 콜백이 UI 경계에서 오므로 race 조건 예방
    @MainActor
    private func complete(_ result: Result<AppleIDTokenResult, Error>) {
        let cont = continuation
        continuation = nil
        currentNonce = nil
        currentAnchor = nil

        switch result {
        case .success(let value):
            cont?.resume(returning: value) // async signIn() 성공 반환
        case .failure(let error):
            cont?.resume(throwing: error) // async signIn() 에러 반환
        }
    }

    // 현재 보이는 메인 창(key window)을 찾는 함수. 찾아서 Apple 로그인 시트 앵커로 사용.
    // MainActor 이유: UIApplication/Scene/Window 접근은 메인에서 처리하는 게 원칙.
    @MainActor
    private static func findPresentationAnchor() -> ASPresentationAnchor? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

// Apple 로그인 결과(delegate)를 받는 부분.
extension AppleSignInProvider: ASAuthorizationControllerDelegate {

    // 성공 콜백.
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        // credential 타입 확인.
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Task { @MainActor in self.complete(.failure(AppleAuthError.invalidCredential)) }
            return
        }

        // signIn 시작 시 저장해둔 raw nonce 존재 확인.
        guard let nonce = currentNonce else {
            Task { @MainActor in self.complete(.failure(AppleAuthError.missingNonce)) }
            return
        }

        // Apple identityToken(JWT) 추출 및 문자열 변환.
        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8),
              !idToken.isEmpty else {
            Task { @MainActor in self.complete(.failure(AppleAuthError.missingIdentityToken)) }
            return
        }

        // UseCase/Repository가 필요로 하는 결과(idToken + raw nonce)로 변환하여 성공 반환.
        let formatter = PersonNameComponentsFormatter()
        let fullNameString = credential.fullName.flatMap { formatter.string(from: $0) }
        let normalizedFullName = fullNameString?.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeFullName = (normalizedFullName?.isEmpty == true) ? nil : normalizedFullName

        Task { @MainActor in
            self.complete(
                .success(
                    AppleIDTokenResult(
                        idToken: idToken,
                        nonce: nonce,
                        email: credential.email,
                        fullName: safeFullName
                    )
                )
            )
        }
    }

    // 실패 콜백.
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // 사용자 취소는 별도 분기(.cancelled) 처리.
        let mapped: AppleAuthError
        if let appleError = error as? ASAuthorizationError,
           appleError.code == .canceled {
            mapped = .cancelled
        } else {
            mapped = .invalidCredential // 나머지는 현재 정책상 인증 실패로 매핑
        }

        Task { @MainActor in
            self.complete(.failure(mapped))
        }
    }
}

// Apple 로그인 시트 표시 위치(window)를 제공하는 프로토콜 구현.
extension AppleSignInProvider: ASAuthorizationControllerPresentationContextProviding {
    @MainActor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let anchor = currentAnchor {
            return anchor // signIn()에서 세팅한 정상 앵커 사용
        }

        // 방어 코드: 키 윈도우 재탐색.
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            return window
        }

        // iOS 26+ deprecation 대응: 기본 init() 대신 windowScene 기반 생성.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return UIWindow(windowScene: scene)
        }

        // 어떤 scene/window도 없으면 Apple 로그인 UI를 띄울 수 없으므로 치명 오류.
        fatalError("No UIWindowScene available for Apple Sign In presentation anchor.")
    }
}
