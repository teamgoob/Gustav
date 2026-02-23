//
//  AppDIContainer.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import Foundation

enum AppDIContainer {

    // SupabaseClient는 앱 전체에서 하나만 쓰는 게 안전
    private static let client = SupabaseClientProvider.create()

    // SessionStore도 하나만 공유
    private static let sessionStore: KeychainSessionStore = {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            fatalError("Bundle Identifier not found")
        }
        return KeychainSessionStore(service: bundleID + ".auth.session")
    }()

    static func makeAuthUsecase() -> AuthUsecaseProtocol {

        let appleProvider = AppleSignInProvider()

        let profileDataSource = ProfileSupabase(client: client)
        let profileRepository = ProfileRepository(dataSource: profileDataSource)

        let authDataSource = AuthSupabase(client: client)
        let authRepository = AuthRepository(
            appleProvider: appleProvider,
            dataSource: authDataSource,
            profileRepository: profileRepository,
            sessionStore: sessionStore
        )

        return AuthUsecase(
            authRepository: authRepository,
            sessionStore: sessionStore
        )
    }

    static func makeProfileUsecase() -> ProfileUsecaseProtocol {

        let appleProvider = AppleSignInProvider()

        let profileDataSource = ProfileSupabase(client: client)
        let profileRepository = ProfileRepository(dataSource: profileDataSource)

        let authDataSource = AuthSupabase(client: client)
        let authRepository = AuthRepository(
            appleProvider: appleProvider,
            dataSource: authDataSource,
            profileRepository: profileRepository,
            sessionStore: sessionStore
        )

        return ProfileUsecase(
            authRepo: authRepository,
            profileRepo: profileRepository
        )
    }
}
