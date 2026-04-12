//
//  AppDIContainer.swift
//  Gustav
//
//  Created by kaeun on 2/23/26.
//

import UIKit
import Supabase
import AuthenticationServices

// MARK: - AppDIContainer
// 앱 전역에 공유되는 의존성 관리
final class AppDIContainer: AppDIContainerProtocol  {
    
    // MARK: - Core
    // Presentation Anchor Provider
    private let presentationAnchorProvider: () -> ASPresentationAnchor
    // Supabase Client
    private lazy var supabaseClient: SupabaseClient = {
        SupabaseClientProvider.create()
    }()
    // Apple Auth Provider
    private lazy var appleAuthProvider: AppleAuthProvider = {
        AppleAuthProvider()
    }()
    // Initializer
    /* SceneDelegate에서 생성
     let container = AppDIContainer(presentationAnchorProvider: { window })
     */
    init(presentationAnchorProvider: @escaping () -> ASPresentationAnchor) {
        self.presentationAnchorProvider = presentationAnchorProvider
    }
    
    func handleAuthCallback(_ url: URL) async throws {
        try await supabaseClient.auth.session(from: url)
    }
    
    
    
    // MARK: - App Flow Factory
    // MARK: - ⭐️ 화면용 ViewModel factory 구현 필요
    func makeAuthDIContainer() -> AuthDIContainer {
        AuthDIContainer(appDIContainer: self)
    }
    
    func makeWorkspaceListDIContainer() -> WorkspaceListDIContainer {
        WorkspaceListDIContainer(appContainer: self)
    }
    
    func makeCategoryListDIContainer() -> CategoryListDIContainer {
        CategoryListDIContainer(appContainer: self)
    }
    
    func makeLocationListDIContainer() -> LocationListDIContainer {
        LocationListDIContainer(appContainer: self)
    }
    
    func makeItemStateListDIContainer() -> ItemStateListDIContainer {
        ItemStateListDIContainer(appContainer: self)
    }
    
    // MARK: - Remote Data Source
    // Auth Supabase
    private lazy var authSupabase: AuthDataSourceProtocol = {
        AuthSupabase(client: supabaseClient)
    }()
    // Apple account link datasource
    private lazy var appleAccountLinkDataSource: AppleAccountLinkDataSourceProtocol = {
        AppleAccountLinkDataSource(
            client: supabaseClient,
            baseURL: AppEnvironment.supabaseFunctionsURL
        )
    }()
    // Profile Supabase
    private lazy var profileSupabase: ProfileDataSourceProtocol = {
        ProfileSupabase(client: supabaseClient)
    }()
    // Profile Image Supabase
    private lazy var profileImageSupabase: ProfileImageDataSourceProtocol = {
        ProfileImageSupabase(client: supabaseClient)
    }()
    // Workspace Supabase
    private lazy var workspaceSupabase: WorkspaceDataSourceProtocol = {
        WorkspaceSupabase(client: supabaseClient)
    }()
    // Item Supabase
    private lazy var itemSupabase: ItemDataSourceProtocol = {
        ItemSupabase(client: supabaseClient)
    }()
    // Category Supabase
    private lazy var categorySupabase: CategoryDataSourceProtocol = {
        CategorySupabase(client: supabaseClient)
    }()
    // ItemState Supabase
    private lazy var itemStateSupabase: ItemStateDataSourceProtocol = {
        ItemStateSupabase(client: supabaseClient)
    }()
    // Location Supabase
    private lazy var locationSupabase: LocationDataSourceProtocol = {
        LocationSupabase(client: supabaseClient)
    }()
    // View Preset Supabase
    private lazy var viewPresetSupabase: ViewPresetDataSourceProtocol = {
        ViewPresetSupabase(client: supabaseClient)
    }()
    
    // MARK: - Cache Data Source
    // Workspace Cache
    private lazy var workspaceCache: WorkspaceCache = {
        WorkspaceCache()
    }()
    // Category Cache
    private lazy var categoryCache: CategoryCache = {
        CategoryCache()
    }()
    // ItemState Cache
    private lazy var itemStateCache: ItemStateCache = {
        ItemStateCache()
    }()
    // Location Cache
    private lazy var locationCache: LocationCache = {
        LocationCache()
    }()
    
    // MARK: - Repository
    // Auth Flow Repository
    private lazy var authFlowRepository: AuthFlowRepositoryProtocol = {
        AuthFlowRepository(
            authDataSource: authSupabase,
            profileDataSource: profileSupabase
        )
    }()
    // Auth Session Repository
    private lazy var authSessionRepository: AuthSessionRepositoryProtocol = {
        AuthSessionRepository(
            appleAuthProvider: appleAuthProvider,
            authDataSource: authSupabase,
            appleAccountLinkDataSource: appleAccountLinkDataSource,
            profileDataSource: profileSupabase,
            presentationAnchorProvider: presentationAnchorProvider
        )
    }()
    // Profile Repository
    private lazy var profileRepository: ProfileRepositoryProtocol = {
        ProfileRepository(dataSource: profileSupabase)
    }()
    // Profile Image Repository
    private lazy var profileImageRepository: ProfileImageRepositoryProtocol = {
        ProfileImageRepository(remote: profileImageSupabase)
    }()
    // Workspace Repository
    private lazy var workspaceRepository: WorkspaceRepositoryProtocol = {
        WorkspaceRepository(remote: workspaceSupabase, cache: workspaceCache)
    }()
    // Item Repository
    private lazy var itemRepository: ItemRepositoryProtocol = {
        ItemRepository(remote: itemSupabase)
    }()
    // Category Repository
    private lazy var categoryRepository: CategoryRepositoryProtocol = {
        CategoryRepository(dataSource: categorySupabase, cache: categoryCache)
    }()
    // ItemState Repository
    private lazy var itemStateRepository: ItemStateRepositoryProtocol = {
        ItemStateRepository(dataSource: itemStateSupabase, cache: itemStateCache)
    }()
    // Location Repository
    private lazy var locationRepository: LocationRepositoryProtocol = {
        LocationRepository(dataSource: locationSupabase, cache: locationCache)
    }()
    // View Preset Repository
    private lazy var viewPresetRepository: ViewPresetRepositoryProtocol = {
        ViewPresetRepository(dataSource: viewPresetSupabase)
    }()
    
    // MARK: - Usecase
    // Auth Usecase
    lazy var authUsecase: AuthUseCaseProtocol = {
        AuthUseCase(flowRepository: authFlowRepository, sessionRepository: authSessionRepository)
    }()
    // Profile Usecase
    lazy var profileUsecase: ProfileUseCaseProtocol = {
        ProfileUseCase(repository: profileRepository)
    }()
    // Profile Image Usecase
    lazy var profileImageUsecase: ProfileImageUsecaseProtocol = {
        ProfileImageUsecase(repository: profileImageRepository)
    }()
    // Workspace Usecase
    lazy var workspaceUsecase: WorkspaceUsecaseProtocol = {
        WorkspaceUsecase(authFlowRepository: authFlowRepository, workspaceRepository: workspaceRepository)
    }()
    // Workspace Context Usecase
    lazy var workspaceContextUsecase: WorkspaceContextUsecaseProtocol = {
        WorkspaceContextUsecase(workspaceRepo: workspaceRepository, categoryRepo: categoryRepository, locationRepo: locationRepository, stateRepo: itemStateRepository)
    }()
    // Item Usecase
    lazy var itemUsecase: ItemUsecaseProtocol = {
        ItemUsecase(repository: itemRepository)
    }()
    // Item Reference Usecase
    lazy var itemReferenceUsecase: ItemReferenceUsecaseProtocol = {
        ItemReferenceUsecase(itemRepository: itemRepository, categoryRepository: categoryRepository, locationRepository: locationRepository, itemStateRepository: itemStateRepository)
    }()
    // Item Query Usecase
    lazy var itemQueryUsecase: ItemQueryUsecaseProtocol = {
        ItemQueryUsecase(itemRepository: itemRepository)
    }()
    // Category Usecase
    lazy var categoryUsecase: CategoryUsecaseProtocol = {
        CategoryUsecase(repository: categoryRepository)
    }()
    // ItemState Usecase
    lazy var itemStateUsecase: ItemStateUsecaseProtocol = {
        ItemStateUsecase(repository: itemStateRepository)
    }()
    // Location Usecase
    lazy var locationUsecase: LocationUsecaseProtocol = {
        LocationUsecase(repository: locationRepository)
    }()
    // View Preset Usecase
    lazy var viewPresetUsecase: ViewPresetUsecaseProtocol = {
        ViewPresetUsecase(repository: viewPresetRepository)
    }()
}
