//
//  GustavTests.swift
//  GustavTests
//
//  Created by 최명수 on 2026/2/9.
//

import XCTest
import UIKit
import AuthenticationServices
@testable import Gustav

final class GustavTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testValidatePasswordRequiresLetterAndDigit() throws {
        let validator = DefaultAuthValidator()

        XCTAssertEqual(
            validator.validatePassword("12345678", minLength: 8),
            .passwordMissingLetterOrDigit
        )

        XCTAssertEqual(
            validator.validatePassword("abcdefgh", minLength: 8),
            .passwordMissingLetterOrDigit
        )

        XCTAssertNil(
            validator.validatePassword("abc12345", minLength: 8)
        )
    }

    func testAppleDeletionPolicyDefaultsToConfirmOnly() {
        let viewModel = AccountDeletingViewModel(
            authUsecase: TestAuthUsecase(),
            profileUsecase: TestProfileUsecase()
        )

        XCTAssertEqual(
            viewModel.makeVerificationPolicy(
                provider: .apple,
                email: "relay@privaterelay.appleid.com",
                isPrivateEmail: true
            ),
            .confirmOnly
        )
    }

    func testAppleWithdrawalUsesStoredTokenWithoutReauthentication() async {
        let authDataSource = AuthDataSourceStub()
        authDataSource.provider = .apple

        let appleAuthProvider = AppleAuthProviderStub()
        let appleLinkDataSource = AppleAccountLinkDataSourceStub()
        appleLinkDataSource.withdrawResults = [.success(())]

        let repository = AuthSessionRepository(
            appleAuthProvider: appleAuthProvider,
            authDataSource: authDataSource,
            appleAccountLinkDataSource: appleLinkDataSource,
            profileDataSource: ProfileDataSourceStub(),
            presentationAnchorProvider: { UIWindow() }
        )

        let result = await repository.withdraw()

        switch result {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected withdrawal to succeed without reauthentication, got \(error)")
        }

        XCTAssertEqual(appleAuthProvider.signInCallCount, 0)
        XCTAssertEqual(appleLinkDataSource.withdrawCallCount, 1)
    }

    func testAppleWithdrawalReauthenticatesAndRetriesWhenStoredTokenDeletionFails() async {
        let authDataSource = AuthDataSourceStub()
        authDataSource.provider = .apple
        authDataSource.authenticateWithAppleResult = .success(
            AuthDTO(
                accessToken: "access",
                refreshToken: "refresh",
                userId: UUID(),
                expiresAt: nil,
                provider: "apple"
            )
        )

        let appleAuthProvider = AppleAuthProviderStub()
        appleAuthProvider.result = .success(
            AppleIDTokenResult(
                idToken: "identity-token",
                nonce: "nonce",
                authorizationCode: "authorization-code",
                email: nil,
                fullName: nil
            )
        )

        let appleLinkDataSource = AppleAccountLinkDataSourceStub()
        appleLinkDataSource.withdrawResults = [
            .failure(.unknown),
            .success(())
        ]

        let repository = AuthSessionRepository(
            appleAuthProvider: appleAuthProvider,
            authDataSource: authDataSource,
            appleAccountLinkDataSource: appleLinkDataSource,
            profileDataSource: ProfileDataSourceStub(),
            presentationAnchorProvider: { UIWindow() }
        )

        let result = await repository.withdraw()

        switch result {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected withdrawal to succeed after Apple reauthentication, got \(error)")
        }

        XCTAssertEqual(appleAuthProvider.signInCallCount, 1)
        XCTAssertEqual(appleLinkDataSource.registerCallCount, 1)
        XCTAssertEqual(appleLinkDataSource.withdrawCallCount, 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

private final class AuthDataSourceStub: AuthDataSourceProtocol {
    var provider: AuthProvider = .unknown
    var authenticateWithAppleResult: RepositoryResult<AuthDTO> = .failure(.unknown)

    func authenticateWithApple(idToken: String, nonce: String) async -> RepositoryResult<AuthDTO> {
        authenticateWithAppleResult
    }

    func signInWithEmail(email: String, password: String) async -> RepositoryResult<AuthDTO> {
        .failure(.unknown)
    }

    func currentSession() async -> RepositoryResult<AuthDTO?> {
        .success(nil)
    }

    func validSession() async -> RepositoryResult<AuthDTO?> {
        .success(nil)
    }

    func signUpWithEmail(email: String, password: String) async -> RepositoryResult<EmailSignUpOutcomeDTO> {
        .failure(.unknown)
    }

    func resetPassword(email: String) async -> RepositoryResult<Void> {
        .failure(.unknown)
    }

    func signOut() async -> RepositoryResult<Void> {
        .success(())
    }

    func withdrawCurrentUser() async -> RepositoryResult<Void> {
        .success(())
    }

    func currentAuthProvider() -> AuthProvider {
        provider
    }

    func currentUserId() -> UUID? {
        nil
    }
}

private final class AppleAuthProviderStub: AppleAuthProviding {
    var signInCallCount = 0
    var result: Result<AppleIDTokenResult, AppleAuthError> = .failure(.cancelled)

    func signIn(presentationAnchor: ASPresentationAnchor) async -> Result<AppleIDTokenResult, AppleAuthError> {
        signInCallCount += 1
        return result
    }
}

private final class AppleAccountLinkDataSourceStub: AppleAccountLinkDataSourceProtocol {
    var registerCallCount = 0
    var withdrawCallCount = 0
    var registerResult: RepositoryResult<Void> = .success(())
    var withdrawResults: [RepositoryResult<Void>] = [.failure(.unknown)]

    func registerAppleAuthorizationCode(
        authorizationCode: String,
        identityToken: String
    ) async -> RepositoryResult<Void> {
        registerCallCount += 1
        return registerResult
    }

    func withdrawCurrentAccount() async -> RepositoryResult<Void> {
        let resultIndex = min(withdrawCallCount, max(withdrawResults.count - 1, 0))
        let result = withdrawResults[resultIndex]
        withdrawCallCount += 1
        return result
    }
}

private final class ProfileDataSourceStub: ProfileDataSourceProtocol {
    func fetchProfile(userId: UUID) async -> RepositoryResult<ProfileDTO> {
        .failure(.notFound)
    }

    func updateUserName(userId: UUID, name: String) async -> RepositoryResult<Void> {
        .success(())
    }

    func upsertProfile(
        userId: UUID,
        email: String?,
        displayName: String?
    ) async -> RepositoryResult<Void> {
        .success(())
    }
}
