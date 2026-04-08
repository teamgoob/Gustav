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
        
        case didTapViewType
        case didTapSortBy
        case didTapSortOrder
        case didTapCategory
        case didTapLocation
        case didTapItemStatus
        case didTapSave
        case didTapBack
        
        case didSelectViewType(String)
        case didSelectSortBy(String)
        case didSelectSortOrder(String)
        case didSelectCategory(UUID)
        case didSelectLocation(UUID)
        case didSelectItemStatus(UUID)
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
    
    // MARK: - Route
    enum Route {
        case showOptionPopup(OptionPopupRoute)
        case pop
        case showValidationAlert(String)
        case showSaveFailureAlert(String)
        case showSaveSuccess
    }
    
    struct OptionPopupRoute {
        let title: String
        let items: [OptionPopupItem]
        let selectedID: String?
    }
    
    // MARK: - Closures
    var onDisplay: ((Output) -> Void)?
    var onNavigation: ((Route) -> Void)?
    
    // MARK: - Properties
    private let viewPresetUsecase: ViewPresetUsecaseProtocol
    private let context: PresetAddContext
    
    private var currentName: String = ""
    private var currentViewType: Int = 0
    private var currentSortingOption: SortingOption?
    private var currentFilters: [FilterOption] = []
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
            
        case .didChangeName(let name):
            currentName = name
            notifyOutput()
            
        case .didTapViewType:
            onNavigation?(.showOptionPopup(makeViewTypePopupRoute()))
            
        case .didTapSortBy:
            onNavigation?(.showOptionPopup(makeSortByPopupRoute()))
            
        case .didTapSortOrder:
            onNavigation?(.showOptionPopup(makeSortOrderPopupRoute()))
            
        case .didTapCategory:
            onNavigation?(.showOptionPopup(makeCategoryPopupRoute()))
            
        case .didTapLocation:
            onNavigation?(.showOptionPopup(makeLocationPopupRoute()))
            
        case .didTapItemStatus:
            onNavigation?(.showOptionPopup(makeItemStatePopupRoute()))
            
        case .didTapSave:
            savePreset()
            
        case .didTapBack:
            onNavigation?(.pop)
            
        case .didSelectViewType(let id):
            guard let viewType = Int(id) else { return }
            currentViewType = viewType
            notifyOutput()
            
        case .didSelectSortBy(let id):
            let currentOrder = extractSortingOrder(from: currentSortingOption) ?? .ascending
            currentSortingOption = makeSortingOption(from: id, order: currentOrder)
            notifyOutput()
            
        case .didSelectSortOrder(let id):
            let sortByID = sortingOptionID(currentSortingOption) ?? "indexKey"
            let newOrder: SortingOrder = id == "desc" ? .descending : .ascending
            currentSortingOption = makeSortingOption(from: sortByID, order: newOrder)
            notifyOutput()
            
        case .didSelectCategory(let id):
            currentFilters = replacingCategoryFilter(with: id, in: currentFilters)
            notifyOutput()
            
        case .didSelectLocation(let id):
            currentFilters = replacingLocationFilter(with: id, in: currentFilters)
            notifyOutput()
            
        case .didSelectItemStatus(let id):
            currentFilters = replacingItemStateFilter(with: id, in: currentFilters)
            notifyOutput()
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
            category: mapCategoryText(from: currentFilters),
            location: mapLocationText(from: currentFilters),
            itemStatus: mapItemStatusText(from: currentFilters),
            isSaveEnabled: validateForSave(),
            isSaving: isSaving
        )
        
        onDisplay?(output)
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
        guard let sortingOption else { return nil }
        
        switch sortingOption {
        case .indexKey:
            return "Basic"
        case .name:
            return "Name"
        case .nameDetail:
            return "Detail Name"
        case .purchaseDate:
            return "Purchase Date"
        case .purchasePlace:
            return "Purchase Place"
        case .expireDate:
            return "Expire Date"
        case .price:
            return "Price"
        case .quantity:
            return "Quantity"
        case .createdAt:
            return "Created At"
        case .updatedAt:
            return "Updated At"
        }
    }
    
    func mapSortingOrderToText(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        
        switch sortingOption {
        case .indexKey(let order),
                .name(let order),
                .nameDetail(let order),
                .purchaseDate(let order),
                .purchasePlace(let order),
                .expireDate(let order),
                .price(let order),
                .quantity(let order),
                .createdAt(let order),
                .updatedAt(let order):
            return mapSortingOrderText(order)
        }
    }
    
    func mapSortingOrderText(_ order: SortingOrder) -> String {
        switch order {
        case .ascending:
            return "Ascending"
        case .descending:
            return "Descending"
        }
    }
    
    func extractSortingOrder(from sortingOption: SortingOption?) -> SortingOrder? {
        guard let sortingOption else { return nil }
        
        switch sortingOption {
        case .indexKey(let order),
                .name(let order),
                .nameDetail(let order),
                .purchaseDate(let order),
                .purchasePlace(let order),
                .expireDate(let order),
                .price(let order),
                .quantity(let order),
                .createdAt(let order),
                .updatedAt(let order):
            return order
        }
    }
    
    func makeSortingOption(from id: String, order: SortingOrder) -> SortingOption {
        switch id {
        case "indexKey":
            return .indexKey(order: order)
        case "name":
            return .name(order: order)
        case "nameDetail":
            return .nameDetail(order: order)
        case "purchaseDate":
            return .purchaseDate(order: order)
        case "purchasePlace":
            return .purchasePlace(order: order)
        case "expireDate":
            return .expireDate(order: order)
        case "price":
            return .price(order: order)
        case "quantity":
            return .quantity(order: order)
        case "createdAt":
            return .createdAt(order: order)
        case "updatedAt":
            return .updatedAt(order: order)
        default:
            return .indexKey(order: order)
        }
    }
    
    func sortingOptionID(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        
        switch sortingOption {
        case .indexKey:
            return "indexKey"
        case .name:
            return "name"
        case .nameDetail:
            return "nameDetail"
        case .purchaseDate:
            return "purchaseDate"
        case .purchasePlace:
            return "purchasePlace"
        case .expireDate:
            return "expireDate"
        case .price:
            return "price"
        case .quantity:
            return "quantity"
        case .createdAt:
            return "createdAt"
        case .updatedAt:
            return "updatedAt"
        }
    }
    
    func extractCategoryID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .category(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    func extractLocationID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .location(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    func extractItemStateID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .itemState(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    func mapCategoryText(from filters: [FilterOption]) -> String? {
        guard let id = extractCategoryID(from: filters) else { return nil }
        return context.categoryNameByID[id]
    }
    
    func mapLocationText(from filters: [FilterOption]) -> String? {
        guard let id = extractLocationID(from: filters) else { return nil }
        return context.locationNameByID[id]
    }
    
    func mapItemStatusText(from filters: [FilterOption]) -> String? {
        guard let id = extractItemStateID(from: filters) else { return nil }
        return context.itemStateNameByID[id]
    }
    
    func replacingCategoryFilter(with id: UUID, in filters: [FilterOption]) -> [FilterOption] {
        let filtered = filters.filter {
            if case .category = $0 { return false }
            return true
        }
        return filtered + [.category(id)]
    }
    
    func replacingLocationFilter(with id: UUID, in filters: [FilterOption]) -> [FilterOption] {
        let filtered = filters.filter {
            if case .location = $0 { return false }
            return true
        }
        return filtered + [.location(id)]
    }
    
    func replacingItemStateFilter(with id: UUID, in filters: [FilterOption]) -> [FilterOption] {
        let filtered = filters.filter {
            if case .itemState = $0 { return false }
            return true
        }
        return filtered + [.itemState(id)]
    }
    
    func makeCategoryPopupRoute() -> OptionPopupRoute {
        let items = context.categoryNameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                OptionPopupItem(
                    id: key.uuidString,
                    title: value
                )
            }
        
        let selectedID = extractCategoryID(from: currentFilters)?.uuidString
        
        return OptionPopupRoute(
            title: "Category",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeLocationPopupRoute() -> OptionPopupRoute {
        let items = context.locationNameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                OptionPopupItem(
                    id: key.uuidString,
                    title: value
                )
            }
        
        let selectedID = extractLocationID(from: currentFilters)?.uuidString
        
        return OptionPopupRoute(
            title: "Location",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeItemStatePopupRoute() -> OptionPopupRoute {
        let items = context.itemStateNameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                OptionPopupItem(
                    id: key.uuidString,
                    title: value
                )
            }
        
        let selectedID = extractItemStateID(from: currentFilters)?.uuidString
        
        return OptionPopupRoute(
            title: "Item State",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeSortByPopupRoute() -> OptionPopupRoute {
        let options = availableSortingOptions()
        
        let items = options.map {
            OptionPopupItem(
                id: sortingOptionID($0) ?? "",
                title: mapSortingOptionToText($0) ?? ""
            )
        }
        
        let selectedID = sortingOptionID(currentSortingOption)
        
        return OptionPopupRoute(
            title: "Sort By",
            items: items,
            selectedID: selectedID
        )
    }
    
    func availableSortingOptions() -> [SortingOption] {
        [
            .indexKey(order: .ascending),
            .name(order: .ascending),
            .nameDetail(order: .ascending),
            .purchaseDate(order: .ascending),
            .purchasePlace(order: .ascending),
            .expireDate(order: .ascending),
            .price(order: .ascending),
            .quantity(order: .ascending),
            .createdAt(order: .ascending),
            .updatedAt(order: .ascending)
        ]
    }
    
    func makeViewTypePopupRoute() -> OptionPopupRoute {
        let items = [
            OptionPopupItem(id: "0", title: "Basic")
        ]
        let selectedID = String(currentViewType)
        
        return OptionPopupRoute(
            title: "View Type",
            items: items,
            selectedID: selectedID
        )
    }
    
    func makeSortOrderPopupRoute() -> OptionPopupRoute {
        let items = [
            OptionPopupItem(id: "asc", title: "Ascending"),
            OptionPopupItem(id: "desc", title: "Descending")
        ]
        
        let selectedID: String?
        
        if let order = extractSortingOrder(from: currentSortingOption) {
            selectedID = order == .ascending ? "asc" : "desc"
        } else {
            selectedID = nil
        }
        
        return OptionPopupRoute(
            title: "Sort Order",
            items: items,
            selectedID: selectedID
        )
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
