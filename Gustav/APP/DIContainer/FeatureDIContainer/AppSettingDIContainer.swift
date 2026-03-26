//
//  AppSettingDIContainer.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/12.
//

import Foundation

// MARK: - AppSettingDIContainer
// AppSettingCoordinator에서 사용하는 ViewModel들을 생성하는 FeatureDIContainer
final class AppSettingDIContainer {
    // MARK: - AppDIContainer
    private let appDIContainer: AppDIContainer
    
    // MARK: - Initializer
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - ViewModel Builder
    // AppSettingViewModel
    func makeAppSettingViewModel() -> AppSettingViewModel {
        AppSettingViewModel(authUsecase: appDIContainer.authUsecase, profileUsecase: appDIContainer.profileUsecase)
    }
    // ProfileEditingViewModel
    func makeProfileEditingViewModel() -> ProfileEditingViewModel {
        ProfileEditingViewModel(authUsecase: appDIContainer.authUsecase, profileUsecase: appDIContainer.profileUsecase, profileImageUsecase: appDIContainer.profileImageUsecase)
    }
    // AccountDeletingViewModel
    func makeAccountDeletingViewModel() -> AccountDeletingViewModel {
        AccountDeletingViewModel(authUsecase: appDIContainer.authUsecase, profileUsecase: appDIContainer.profileUsecase)
    }
}
