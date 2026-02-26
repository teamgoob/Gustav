//
//  AppleSignInProvider.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation
import AuthenticationServices
import CryptoKit

/// AppleAuthProvider의 역할
/// 1) Apple 로그인 UI를 띄운다.
/// 2) 성공하면 idToken + nonce(원문) + (email/fullName)를 반환한다.
/// 3) 실패하면 AppleAuthError(또는 Error)를 던진다.
///
/// ⚠️ 중요 포인트
/// - nonce는 "요청을 시작할 때" 만들고, "응답을 받을 때" 같은 값을 써야 함
/// - Apple request에는 sha256(nonce)로 넣고
/// - Supabase에는 nonce 원문을 보내야 함
final class AppleAuthProvider: NSObject, AppleAuthProviding {

    /// async/await로 결과를 돌려주기 위한 "임시 저장소"
    /// - Apple 로그인은 원래 delegate 방식(콜백)이라 바로 return을 못 함
    /// - 그래서 signIn()에서 continuation을 만들어 저장해두고,
    /// - 콜백(delegate)이 오면 continuation.resume(...) 해서 결과를 돌려줌
    private var continuation: CheckedContinuation<AppleIDTokenResult, Error>?

    /// nonce 원문을 저장하는 변수
    /// - signIn 시작 시 만든 nonce를 여기 저장
    /// - 성공 콜백이 왔을 때 같은 nonce를 사용해서 결과를 만든다
    private var currentNonce: String?

    /// 로그인 중복 호출 방지용
    /// - 사용자가 버튼을 여러 번 눌러도 Apple 로그인 요청이 꼬이지 않게 막는다
    private var isInProgress = false

    /// Apple 로그인 UI를 띄우기 위한 anchor(Window)
    /// - Apple 로그인 UI는 반드시 "어떤 창 위에 띄울지" 알아야 함
    /// - UIKit을 Provider가 직접 찾지 않고, 외부에서 주입받기 위해 저장해 둠
    private var anchor: ASPresentationAnchor?

    /// Apple 로그인 시작 함수 (외부에서 window를 주입해야 함)
    /// - presentationAnchor: 로그인 UI를 띄울 창(Window)
    func signIn(presentationAnchor: ASPresentationAnchor) async throws -> AppleIDTokenResult {

        // 이미 진행 중이면 에러로 막는다(중복 요청 방지)
        if isInProgress { throw AppleAuthError.inProgress }
        isInProgress = true

        // 외부에서 받은 anchor 저장 (나중에 presentationAnchor(...)에서 사용)
        self.anchor = presentationAnchor

        // delegate 기반 API를 async/await로 바꾸는 핵심 부분
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            // 1) nonce 생성(원문)
            // - nonce는 무작위 문자열
            // - 나중에 Supabase에도 보내야 하므로 원문을 저장해둔다
            let nonce = Nonce.randomString()
            self.currentNonce = nonce

            // 2) Apple에는 nonce 원문이 아니라 sha256(nonce)를 넣는다
            // - Apple이 응답에 nonce 관련 검증을 할 수 있도록 하는 용도
            let hashedNonce = Nonce.sha256(nonce)

            // 3) Apple 로그인 요청 생성
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()

            // 이메일/이름은 "최초 동의(첫 로그인)" 때만 내려올 수 있음
            request.requestedScopes = [.fullName, .email]

            // Apple 요청에 hashed nonce를 넣는다(중요)
            request.nonce = hashedNonce

            // 4) 컨트롤러 실행
            // - performRequests()를 호출하면 시스템 Apple 로그인 UI가 뜬다
            // - 결과는 delegate에서 받는다
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

// MARK: - Apple 로그인 결과를 받는 delegate
extension AppleAuthProvider: ASAuthorizationControllerDelegate {

    /// Apple 로그인 성공 콜백
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        // 함수가 끝날 때 무조건 inProgress 해제
        defer { isInProgress = false }

        // Apple에서 내려준 credential 타입이 맞는지 확인
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            finishWithError(AppleAuthError.invalidCredential)
            return
        }

        // signIn() 시작할 때 저장해 둔 nonce가 있어야 함
        guard let nonce = currentNonce else {
            finishWithError(AppleAuthError.missingNonce)
            return
        }

        // Apple이 준 identityToken(Data)을 String으로 변환
        // 이 String(idToken)을 Supabase에 전달하면 Supabase 세션을 발급받을 수 있다
        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            finishWithError(AppleAuthError.missingIdentityToken)
            return
        }

        // 이메일은 최초 동의 때만 내려올 수 있음(그 후에는 nil 가능)
        let email = credential.email

        // fullName도 최초 동의 때만 내려올 수 있음
        // familyName + givenName을 합쳐서 하나의 문자열로 만든다
        let fullName: String? = {
            let parts = [
                credential.fullName?.familyName,
                credential.fullName?.givenName
            ].compactMap { $0 }

            // 이름 구성 요소가 없으면 nil
            return parts.isEmpty ? nil : parts.joined()
        }()

        // 우리가 앱 내부에서 쓰기 쉬운 결과 타입으로 묶어서 반환
        let result = AppleIDTokenResult(
            idToken: idToken,
            nonce: nonce,
            email: email,
            fullName: fullName
        )

        // async/await로 기다리던 signIn()에게 결과 전달
        continuation?.resume(returning: result)

        // 다음 로그인 요청을 위해 상태 정리
        cleanup()
    }

    /// Apple 로그인 실패 콜백
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // 끝나면 상태 정리
        defer { cleanup() }

        // 사용자가 취소한 경우는 "취소"로 통일 처리
        if let asError = error as? ASAuthorizationError,
           asError.code == .canceled {
            continuation?.resume(throwing: AppleAuthError.cancelled)
            return
        }

        // 그 외 오류는 그대로 던진다
        continuation?.resume(throwing: error)
    }

    /// 에러로 끝낼 때 호출하는 헬퍼
    private func finishWithError(_ error: Error) {
        continuation?.resume(throwing: error)
        cleanup()
    }

    /// 다음 요청을 위해 내부 상태를 초기화
    private func cleanup() {
        continuation = nil
        currentNonce = nil
        anchor = nil
        isInProgress = false
    }
}

// MARK: - Apple 로그인 UI를 띄울 "창(window)" 제공
extension AppleAuthProvider: ASAuthorizationControllerPresentationContextProviding {

    /// Apple 로그인 UI를 어느 창 위에 띄울지 알려주는 함수
    /// - 여기서는 signIn(presentationAnchor:)에서 주입받은 anchor를 그대로 반환
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let anchor else {
            // 여기서 throw를 할 수 없어서, anchor 없이 호출하면 개발자 실수로 판단
            fatalError("Missing presentationAnchor. Pass ASPresentationAnchor into signIn(presentationAnchor:)")
        }
        return anchor
    }
}
