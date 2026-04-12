//
//  AppleAuthProvider.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation
import AuthenticationServices
import CryptoKit

/// AppleAuthProvider의 역할
/// 1) Apple 로그인 UI를 띄웁니다.
/// 2) 성공하면 idToken + raw nonce + authorizationCode + (email/fullName)을 반환합니다.
/// 3) 실패하면 AppleAuthError로 통일해서 던집니다.
///
/// nonce가 왜 필요하냐?
/// - 우리가 만든 raw nonce를 Apple 요청에 sha256로 넣으면,
///   Apple이 발급하는 idToken(JWT) 안에 nonce 값(sha256 형태)이 포함됩니다.
/// - Supabase에 idToken + raw nonce를 같이 보내면,
///   Supabase가 idToken 안 nonce와 raw nonce(sha256 적용 후)가 일치하는지 검증합니다.
/// - 이 검증 덕분에 “토큰 가로채기/재사용” 같은 공격을 막는 데 도움이 됩니다.


final class AppleAuthProvider: NSObject, AppleAuthProviding {
    

    /// delegate 기반 API를 async/await로 바꾸기 위한 저장소
    /// - signIn()에서 continuation을 저장해 둔다.
    /// - delegate 콜백이 오면 resume()으로 결과를 돌려준다.
    private var continuation: CheckedContinuation<Result<AppleIDTokenResult, AppleAuthError>, Never>?

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

    func signIn(presentationAnchor: ASPresentationAnchor)
    async -> Result<AppleIDTokenResult, AppleAuthError> {

        // 이미 로그인 진행 중이면 즉시 실패 반환
        if isInProgress {
            return .failure(.inProgress)
        }

        isInProgress = true
        self.anchor = presentationAnchor

        // delegate → async 변환
        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            // 1) nonce 생성
            let nonce = Nonce.randomString()
            self.currentNonce = nonce

            // 2) Apple 요청에는 sha256(nonce)를 넣는다
            let hashedNonce = Nonce.sha256(nonce)

            // 3) Apple 요청 생성
            let request = ASAuthorizationAppleIDProvider().createRequest()
            /// 최초 로그인 시 email / fullName 받을 수 있음
            request.requestedScopes = [.fullName, .email]
            /// Apple에 전달할 nonce는 해시된 값
            request.nonce = hashedNonce
            
            // 4) 로그인 UI 실행
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }}

// MARK: - Apple 로그인 결과를 받는 delegate
extension AppleAuthProvider: ASAuthorizationControllerDelegate {

    // MARK: - Apple 로그인 성공 콜백
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer { cleanup() } // 끝나면 상태 초기화

        // credential 타입 검증
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            finishWithError(.invalidCredential)
            return
        }

        // raw nonce 존재 확인
        guard let nonce = currentNonce else {
            finishWithError(.missingNonce)
            return
        }

        // idToken(Data → String) 변환
        guard let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            finishWithError(.missingIdentityToken)
            return
        }

        // authorizationCode(Data -> String) 변환
        let authorizationCode: String? = {
            guard let codeData = credential.authorizationCode else { return nil }
            return String(data: codeData, encoding: .utf8)
        }()

        // 최초 로그인 시에만 내려올 수 있음
        let email = credential.email

        // 이름 조합
        let fullName: String? = {
            let parts = [credential.fullName?.familyName, credential.fullName?.givenName]
                .compactMap { $0 }
            return parts.isEmpty ? nil : parts.joined()
        }()
        
        
        // 우리가 앱에서 쓰는 결과 모델로 변환
        let result = AppleIDTokenResult(
            idToken: idToken,
            nonce: nonce,
            authorizationCode: authorizationCode,
            email: email,
            fullName: fullName
        )
        
        // async로 기다리던 signIn()에 성공 전달
        // 성공은 .success로 반환
        continuation?.resume(returning: .success(result))
    }

    // MARK: - Apple 로그인 실패 콜백
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        defer { cleanup() }

        // 사용자가 취소한 경우
        if let asError = error as? ASAuthorizationError,
           asError.code == .canceled {
            continuation?.resume(returning: .failure(.cancelled))
            return
        }

        // 그 외는 보수적으로 invalidCredential로 통일
        continuation?.resume(returning: .failure(.invalidCredential))
    }

    // MARK: - 에러로 끝낼 때 호출하는 헬퍼
    private func finishWithError(_ error: AppleAuthError) {
        continuation?.resume(returning: .failure(error))
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
            // 이 함수는 throw를 지원하지 않습니다.
            // anchor 없이 signIn을 호출한 건 "개발자 실수"라서,
            // 조용히 실패시키면 디버깅이 더 어려워집니다.
            // 그래서 앱을 즉시 크래시 내서 원인을 빨리 찾게 합니다.
            fatalError("Missing presentationAnchor. Pass ASPresentationAnchor into signIn(presentationAnchor:)")
        }
        return anchor
    }
}
