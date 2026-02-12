//
//  AppleAuthError.swift
//  Gustav
//
//  Created by kaeun on 2/13/26.
//


// MARK: - Apple Auth Error

public enum AppleAuthError: Error, Equatable {
    case invalidCredential // Apple SDK에서 기대한 credential 아님
    case missingNonce // 내부 상태 꼬임
    case missingIdentityToken // Apple 응답에 토큰 없음
    case inProgress // 로그인 중 재호출
    case cancelled // 사용자가 취소
    case missingPresentationAnchor // UI 띄울 window 없음
    // 재인증 필요
    // 계정 잠김
}


// MARK: - AppleAuthError → DomainError
extension AppleAuthError {
    func mapToDomainError() -> DomainError {
        switch self {
        case .inProgress,
             .missingPresentationAnchor:
            return .invalidOperation

        case .invalidCredential,
             .missingNonce,
             .missingIdentityToken:
            return .authenticationRequired

        case .cancelled:
            return .cancelled
        }
    }
}
