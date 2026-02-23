//
//  AppDIContainer.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

enum AppDIContainer {
    static func makeAuthUsecase() -> AuthUsecaseProtocol {
        let appleProvider = AppleSignInProvider()
        let authDataSource = AuthSupabase(client: SupabaseClientProvider.create())
        let authRepository = AuthRepository(
            appleProvider: appleProvider,
            dataSource: authDataSource
        )
        let sessionStore = KeychainSessionStore(
            service: Bundle.main.bundleIdentifier ?? "abc"
        )

        return AuthUsecase(
            authRepository: authRepository,
            sessionStore: sessionStore
        )
    }
}
