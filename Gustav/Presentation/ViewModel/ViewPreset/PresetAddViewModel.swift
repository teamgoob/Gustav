//
//  PresetAddViewModel.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//
import Foundation

// MARK: - PresetAddContext
/// 추가 화면에 필요한 고정 데이터를 ViewModel에 전달하기 위한 구조
struct PresetAddContext {
    let workspaceId: UUID
    let categoryNameByID: [UUID: String]
    let locationNameByID: [UUID: String]
    let itemStateNameByID: [UUID: String]
}


// MARK: - PresetAddViewModel
final class PresetAddViewModel {
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case didChangeName(String)
        case didTapSave
        case didTapBack
        case selectViewType(Int)
        case selectSortOption(SortingOption)
        case selectSortOrder(SortingOrder)
        case selectCategoryFilter(UUID?)
        case selectLocationFilter(UUID?)
        case selectItemStateFilter(UUID?)
    }
    
    // MARK: - Output
    struct Output {
        let name: String
        let viewType: String
        let sortingOption: String?
        let sortingOrder: String?
        let category: String?
        let location: String?
        let itemStatus: String?
        let isSaveEnabled: Bool
        let isSaving: Bool
    }
    
    // MARK: - Filter Menu Info
    struct FilterMenuInfo {
        struct ViewTypeOption {
            let id: Int
            let title: String
        }
        
        struct NamedFilterOption {
            let id: UUID
            let title: String
        }
        
        let viewTypeOptions: [ViewTypeOption]
        let sortOptions: [SortingOption]
        let categoryFilters: [NamedFilterOption]
        let locationFilters: [NamedFilterOption]
        let itemStateFilters: [NamedFilterOption]
        
        let currentViewType: Int
        let currentSortOption: SortingOption?
        let currentCategoryID: UUID?
        let currentLocationID: UUID?
        let currentItemStateID: UUID?
    }
    
    // MARK: - Route
    enum Route {
        case pop
        case showValidationAlert(String)
        case showSaveFailureAlert(String)
        case showSaveSuccess
    }
    
    
    // MARK: - Closures
    var onDisplay: ((Output) -> Void)?
    var onFilterMenuChanged: ((FilterMenuInfo) -> Void)?
    var onNavigation: ((Route) -> Void)?
    
    // MARK: - Properties
    private let viewPresetUsecase: ViewPresetUsecaseProtocol
    private let context: PresetAddContext
    
    private var currentName: String = ""
    private var currentViewType: Int = 0
    private var currentSortingOption: SortingOption?
    private var selectedCategoryID: UUID?
    private var selectedLocationID: UUID?
    private var selectedItemStateID: UUID?
    private var isSaving: Bool = false
    
    // MARK: - Init
    init(
        context: PresetAddContext,
        viewPresetUsecase: ViewPresetUsecaseProtocol
    ) {
        self.context = context
        self.viewPresetUsecase = viewPresetUsecase
    }
}

// MARK: - External Methods
extension PresetAddViewModel {
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            notifyOutput()
            notifyFilterMenu()
            
        case .didChangeName(let name):
            currentName = name
            notifyOutput()
            
        case .didTapSave:
            savePreset()
            
        case .didTapBack:
            onNavigation?(.pop)
            
        case .selectViewType(let id):
            currentViewType = id
            notifyOutput()
            notifyFilterMenu()
            
        case .selectSortOption(let option):
            let currentOrder = currentSortingOption?.order ?? option.order
            currentSortingOption = makeSortingOption(
                from: option.sortingOptionCase,
                order: currentOrder
            )
            notifyOutput()
            notifyFilterMenu()
            
        case .selectSortOrder(let order):
            let sortCase = currentSortingOption?.sortingOptionCase ?? .indexKey
            currentSortingOption = makeSortingOption(from: sortCase, order: order)
            notifyOutput()
            notifyFilterMenu()
            
        case .selectCategoryFilter(let id):
            selectedCategoryID = validatedFilterID(
                id,
                from: context.categoryNameByID
            )
            notifyOutput()
            notifyFilterMenu()
            
        case .selectLocationFilter(let id):
            selectedLocationID = validatedFilterID(
                id,
                from: context.locationNameByID
            )
            notifyOutput()
            notifyFilterMenu()
            
        case .selectItemStateFilter(let id):
            selectedItemStateID = validatedFilterID(
                id,
                from: context.itemStateNameByID
            )
            notifyOutput()
            notifyFilterMenu()
        }
    }
}

// MARK: - Private Logic
private extension PresetAddViewModel {
    func notifyOutput() {
        let output = Output(
            name: currentName,
            viewType: mapViewTypeToText(currentViewType),
            sortingOption: mapSortingOptionToText(currentSortingOption),
            sortingOrder: mapSortingOrderToText(currentSortingOption),
            category: mapCategoryText(),
            location: mapLocationText(),
            itemStatus: mapItemStatusText(),
            isSaveEnabled: validateForSave(),
            isSaving: isSaving
        )

        onDisplay?(output)
    }
    
    func notifyFilterMenu() {
        let menu = FilterMenuInfo(
            viewTypeOptions: makeViewTypeOptions(),
            sortOptions: makeSortOptions(),
            categoryFilters: makeNamedFilterOptions(from: context.categoryNameByID),
            locationFilters: makeNamedFilterOptions(from: context.locationNameByID),
            itemStateFilters: makeNamedFilterOptions(from: context.itemStateNameByID),
            currentViewType: currentViewType,
            currentSortOption: currentSortingOption,
            currentCategoryID: selectedCategoryID,
            currentLocationID: selectedLocationID,
            currentItemStateID: selectedItemStateID
        )
        
        onFilterMenuChanged?(menu)
    }
    
    func validateForSave() -> Bool {
        let trimmedName = currentName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty == false && isSaving == false
    }
    
    func mapViewTypeToText(_ viewType: Int) -> String {
        switch viewType {
        case 0:
            return "Basic"
        default:
            return "Basic"
        }
    }
    
    func mapSortingOptionToText(_ sortingOption: SortingOption?) -> String? {
        sortingOption?.toText()
    }
    
    func mapSortingOrderToText(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        return sortingOption.orderToText(isAscending: sortingOption.order == .ascending)
    }
    
    func makeSortingOption(
        from sortCase: SortingOption.SortingOptionCase,
        order: SortingOrder
    ) -> SortingOption {
        switch sortCase {
        case .indexKey:
            return .indexKey(order: order)
        case .name:
            return .name(order: order)
        case .nameDetail:
            return .nameDetail(order: order)
        case .purchaseDate:
            return .purchaseDate(order: order)
        case .purchasePlace:
            return .purchasePlace(order: order)
        case .expireDate:
            return .expireDate(order: order)
        case .price:
            return .price(order: order)
        case .quantity:
            return .quantity(order: order)
        case .createdAt:
            return .createdAt(order: order)
        case .updatedAt:
            return .updatedAt(order: order)
        }
    }
    
    func mapCategoryText() -> String? {
        guard let selectedCategoryID else { return nil }
        return context.categoryNameByID[selectedCategoryID]
    }
    
    func mapLocationText() -> String? {
        guard let selectedLocationID else { return nil }
        return context.locationNameByID[selectedLocationID]
    }
    
    func mapItemStatusText() -> String? {
        guard let selectedItemStateID else { return nil }
        return context.itemStateNameByID[selectedItemStateID]
    }

    func makeViewTypeOptions() -> [FilterMenuInfo.ViewTypeOption] {
        [
            FilterMenuInfo.ViewTypeOption(id: 0, title: "Basic")
        ]
    }
    
    func makeSortOptions() -> [SortingOption] {
        [
            .indexKey(order: .ascending),
            .name(order: .ascending),
            .nameDetail(order: .ascending),
            .purchaseDate(order: .descending),
            .purchasePlace(order: .ascending),
            .expireDate(order: .ascending),
            .price(order: .ascending),
            .quantity(order: .ascending),
            .createdAt(order: .descending),
            .updatedAt(order: .descending)
        ]
    }
    
    func makeNamedFilterOptions(
        from nameByID: [UUID: String]
    ) -> [FilterMenuInfo.NamedFilterOption] {
        nameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                FilterMenuInfo.NamedFilterOption(id: key, title: value)
            }
    }
    
    func validatedFilterID(
        _ id: UUID?,
        from nameByID: [UUID: String]
    ) -> UUID? {
        guard let id, nameByID[id] != nil else { return nil }
        return id
    }
    
    var currentFilters: [FilterOption] {
        [
            selectedCategoryID.map { .category($0) },
            selectedLocationID.map { .location($0) },
            selectedItemStateID.map { .itemState($0) }
        ]
        .compactMap { $0 }
    }
    
    func savePreset() {
        // 사용자가 입력한 이름의 앞뒤 공백/줄바꿈을 제거해서
        // 실제 저장에 사용할 최종 이름을 만듭니다.
        let trimmedName = currentName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 프리셋 이름이 비어 있으면 저장하지 않고
        // 사용자에게 이름 입력이 필요하다는 알림을 보냅니다.
        guard trimmedName.isEmpty == false else {
            onNavigation?(.showValidationAlert("Preset name is required."))
            return
        }
        
        // 정렬 옵션을 아직 선택하지 않았다면
        // 기본값으로 indexKey 오름차순을 사용합니다.
        let sortingOption = currentSortingOption ?? .indexKey(order: .ascending)
        
        // 저장 작업은 비동기로 처리합니다.
        // [weak self]를 사용해서 ViewModel이 해제되어야 할 때
        // Task가 self를 강하게 잡고 있지 않도록 합니다.
        Task { [weak self] in
            guard let self else { return }
            
            // UI 상태 변경은 MainActor에서 처리합니다.
            // 저장 시작 시 isSaving을 true로 바꾸고 화면을 다시 갱신합니다.
            await MainActor.run {
                self.isSaving = true
                self.notifyOutput()
            }
            
            // 현재 입력값들을 기반으로 실제 저장할 ViewPreset 모델을 생성합니다.
            let preset = ViewPreset(
                id: UUID(),
                workspaceId: context.workspaceId,
//                indexKey: 0,
                name: trimmedName,
                viewType: currentViewType,
                sortingOption: sortingOption,
                filters: currentFilters,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // Usecase에 프리셋 생성을 요청합니다.
            // ViewModel이 직접 저장소를 다루지 않고 Usecase를 통해 저장하는 구조입니다.
            let result = await viewPresetUsecase.createViewPreset(
                workspaceId: context.workspaceId,
                preset: preset
            )
            
            // 저장 완료 후 다시 MainActor에서 UI 상태를 복구하고
            // 성공/실패에 따라 다음 화면 동작을 전달합니다.
            await MainActor.run {
                self.isSaving = false
                self.notifyOutput()
                
                switch result {
                case .success:
                    // 저장 성공 시 성공 이벤트를 전달합니다.
                    self.onNavigation?(.showSaveSuccess)
                    
                case .failure(let error):
                    // 저장 실패 시 에러를 사용자 메시지로 변환해서 알림을 보냅니다.
                    let message = self.makeSaveFailureMessage(from: error)
                    self.onNavigation?(.showSaveFailureAlert(message))
                }
            }
        }
    }
    
    func makeSaveFailureMessage(from error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription,
           description.isEmpty == false {
            return description
        }
        
        return "Failed to save preset. Please try again."
    }
}
