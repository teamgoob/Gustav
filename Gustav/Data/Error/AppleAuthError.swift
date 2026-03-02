//
//  AppleAuthError.swift
//  Gustav
//
//  Created by kaeun on 2/13/26.
//


// MARK: - Apple Auth Error

enum AppleAuthError: Error, Equatable {
    case invalidCredential // Apple SDK에서 기대한 credential 아님
    case missingNonce // 내부 상태 꼬임
    case missingIdentityToken // Apple 응답에 토큰 없음
    case inProgress // 로그인 중 재호출
    case cancelled // 사용자가 취소
    case missingPresentationAnchor // UI 띄울 window 없음
    // 재인증 필요
    // 계정 잠김
}

extension AppleAuthError: RepositoryErrorConvertible {
    func mapToRepositoryError() -> RepositoryError {
        switch self {
        case .cancelled:
            return .cancelled

        case .invalidCredential,
             .missingNonce,
             .missingIdentityToken:
            return .invalidCredentials

        case .inProgress,
             .missingPresentationAnchor:
            return .misconfigured
        }
    }
}
