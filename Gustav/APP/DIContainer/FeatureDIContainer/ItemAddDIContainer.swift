//
//  ItemAddDIContainer.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//
import Foundation

/// Item Add 화면에서 필요한 객체를 생성하는 DIContainer
final class ItemAddDIContainer {
    
    // MARK: - Properties
    
    private let appDIContainer: AppDIContainer
    
    // MARK: - Init
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - UseCase Builder
    
    /// 아이템 생성에 사용할 UseCase 생성
    func makeItemUseCase() -> ItemUsecaseProtocol {
        appDIContainer.itemUsecase
    }
    
    /// 카테고리 목록 조회에 사용할 UseCase 생성
    func makeCategoryUseCase() -> CategoryUsecaseProtocol {
        appDIContainer.categoryUsecase
    }
    
    /// 아이템 상태 목록 조회에 사용할 UseCase 생성
    func makeItemStateUseCase() -> ItemStateUsecaseProtocol {
        appDIContainer.itemStateUsecase
    }
    
    /// 위치 목록 조회에 사용할 UseCase 생성
    func makeLocationUseCase() -> LocationUsecaseProtocol {
        appDIContainer.locationUsecase
    }
    
    // MARK: - ViewModel Builder
    
    /// ItemAddViewModel 생성
    func makeItemAddViewModel(workspaceId: UUID) -> ItemAddViewModel {
        ItemAddViewModel(
            workspaceId: workspaceId,
            itemUseCase: makeItemUseCase()
        )
    }
    
    // MARK: - ViewController Builder
    
    /// ItemAddViewController 생성
    /// dropdown popup에 사용할 도메인 모델 목록을 UseCase를 통해 조회한 뒤 함께 주입합니다.
    func makeItemAddViewController(workspaceId: UUID) async -> ItemAddViewController {
        let viewModel = makeItemAddViewModel(workspaceId: workspaceId)
        let viewController = ItemAddViewController(viewModel: viewModel)
        
        async let categoriesResult = makeCategoryUseCase().fetchCategories(workspaceId: workspaceId)
        async let itemStatesResult = makeItemStateUseCase().fetchItemStates(workspaceId: workspaceId)
        async let locationsResult = makeLocationUseCase().fetchLocations(workspaceId: workspaceId)
        
        let categories: [Category]
        switch await categoriesResult {
        case .success(let value):
            categories = value
        case .failure:
            categories = []
        }
        
        let itemStates: [ItemState]
        switch await itemStatesResult {
        case .success(let value):
            itemStates = value
        case .failure:
            itemStates = []
        }
        
        let locations: [Location]
        switch await locationsResult {
        case .success(let value):
            locations = value
        case .failure:
            locations = []
        }
        
        viewController.configureDropdownData(
            categories: categories,
            itemStates: itemStates,
            locations: locations
        )
        
        return viewController
    }
}
