//
//  PresetDetailViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import Foundation

// MARK: - PresetDetailContext
struct PresetDetailContext {
    let preset: ViewPreset
    let workspaceName: String
    let categories: [Category]
    let categoryNameByID: [UUID: String]
    let locationNameByID: [UUID: String]
    let itemStateNameByID: [UUID: String]
}

// MARK: - PresetDetailViewModel
final class PresetDetailViewModel {
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case didTapMore
        case didTapBack
        case selectViewType(Int)
        case selectSortOption(SortingOption)
        case selectSortOrder(SortingOrder)
        case clearSortOption
        case clearSortOrder
        case selectParentCategoryFilter(UUID?)
        case selectChildCategoryFilter(UUID?)
        case selectLocationFilter(UUID?)
        case selectItemStateFilter(UUID?)
    }
    
    // MARK: - Output
    struct Output {
        let title: String
        let workspaceName: String
        let viewType: String
        let sortingOption: String?
        let sortingOrder: String?
        let category: String?
        let subcategory: String?
        let showsSubcategory: Bool
        let location: String?
        let itemStatus: String?
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
        let parentCategoryFilters: [NamedFilterOption]
        let childCategoryFilters: [NamedFilterOption]
        let locationFilters: [NamedFilterOption]
        let itemStateFilters: [NamedFilterOption]
        
        let currentViewType: Int
        let currentSortOption: SortingOption?
        let currentParentCategoryID: UUID?
        let currentChildCategoryID: UUID?
        let currentLocationID: UUID?
        let currentItemStateID: UUID?
    }
    
    // MARK: - Route
    enum Route {
        case showMoreMenu
        case pop
        case showSaveFailureAlert(String)
    }
    
    // MARK: - Closures
    var onDisplay: ((Output) -> Void)?
    var onFilterMenuChanged: ((FilterMenuInfo) -> Void)?
    var onNavigation: ((Route) -> Void)?
    
    // MARK: - Properties
    private let viewPresetUsecase: ViewPresetUsecaseProtocol
    private let context: PresetDetailContext
    
    private var currentViewType: Int
    private var currentSortingOption: SortingOption?
    private var selectedParentCategoryID: UUID?
    private var selectedChildCategoryID: UUID?
    private var selectedLocationID: UUID?
    private var selectedItemStateID: UUID?
    
    // MARK: - Init
    init(context: PresetDetailContext, viewPresetUsecase: ViewPresetUsecaseProtocol) {
        self.viewPresetUsecase = viewPresetUsecase
        self.context = context
        self.currentViewType = context.preset.viewType
        self.currentSortingOption = Self.normalizedSortingOption(context.preset.sortingOption)
        self.selectedLocationID = Self.extractLocationID(from: context.preset.filters)
        self.selectedItemStateID = Self.extractItemStateID(from: context.preset.filters)

        let selectedCategoryID = Self.extractCategoryID(from: context.preset.filters)
        if let selectedCategoryID,
           let category = context.categories.first(where: { $0.id == selectedCategoryID }) {
            if let parentId = category.parentId {
                self.selectedParentCategoryID = parentId
                self.selectedChildCategoryID = category.id
            } else {
                self.selectedParentCategoryID = category.id
                self.selectedChildCategoryID = nil
            }
        }
    }
}

// MARK: - External Methods
extension PresetDetailViewModel {
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            notifyOutput()
            notifyFilterMenu()
            
        case .didTapMore:
            onNavigation?(.showMoreMenu)
            
        case .didTapBack:
            savePresetBeforePop()
            
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
            guard let sortCase = currentSortingOption?.sortingOptionCase else { return }
            currentSortingOption = makeSortingOption(from: sortCase, order: order)
            notifyOutput()
            notifyFilterMenu()
            
        case .clearSortOption:
            currentSortingOption = nil
            notifyOutput()
            notifyFilterMenu()
            
        case .clearSortOrder:
            currentSortingOption = nil
            notifyOutput()
            notifyFilterMenu()
            
        case .selectParentCategoryFilter(let id):
            handleParentCategorySelection(id)
            notifyOutput()
            notifyFilterMenu()

        case .selectChildCategoryFilter(let id):
            handleChildCategorySelection(id)
            notifyOutput()
            notifyFilterMenu()
            
        case .selectLocationFilter(let id):
            selectedLocationID = validatedFilterID(id, from: context.locationNameByID)
            notifyOutput()
            notifyFilterMenu()
            
        case .selectItemStateFilter(let id):
            selectedItemStateID = validatedFilterID(id, from: context.itemStateNameByID)
            notifyOutput()
            notifyFilterMenu()
        }
    }
}

// MARK: - Private Logic
private extension PresetDetailViewModel {
    func notifyOutput() {
        let output = Output(
            title: context.preset.name,
            workspaceName: context.workspaceName,
            viewType: mapViewTypeToText(currentViewType),
            sortingOption: mapSortingOptionToText(currentSortingOption),
            sortingOrder: mapSortingOrderToText(currentSortingOption),
            category: selectedParentCategoryID.flatMap { context.categoryNameByID[$0] },
            subcategory: selectedChildCategoryID.flatMap { context.categoryNameByID[$0] },
            showsSubcategory: currentChildCategories.isEmpty == false,
            location: selectedLocationID.flatMap { context.locationNameByID[$0] },
            itemStatus: selectedItemStateID.flatMap { context.itemStateNameByID[$0] }
        )
        
        onDisplay?(output)
    }
    
    func notifyFilterMenu() {
        let menu = FilterMenuInfo(
            viewTypeOptions: [
                FilterMenuInfo.ViewTypeOption(id: 0, title: "Basic")
            ],
            sortOptions: makeSortOptions(),
            parentCategoryFilters: makeCategoryFilterOptions(from: parentCategories),
            childCategoryFilters: makeCategoryFilterOptions(from: currentChildCategories),
            locationFilters: makeNamedFilterOptions(from: context.locationNameByID),
            itemStateFilters: makeNamedFilterOptions(from: context.itemStateNameByID),
            currentViewType: currentViewType,
            currentSortOption: currentSortingOption,
            currentParentCategoryID: selectedParentCategoryID,
            currentChildCategoryID: selectedChildCategoryID,
            currentLocationID: selectedLocationID,
            currentItemStateID: selectedItemStateID
        )
        
        onFilterMenuChanged?(menu)
    }
    
    var parentCategories: [Category] {
        context.categories.filter { $0.parentId == nil }
    }

    var currentChildCategories: [Category] {
        guard let parentId = selectedParentCategoryID else { return [] }
        return context.categories.filter { $0.parentId == parentId }
    }

    func category(by id: UUID) -> Category? {
        context.categories.first(where: { $0.id == id })
    }

    func handleParentCategorySelection(_ id: UUID?) {
        guard let id else {
            selectedParentCategoryID = nil
            selectedChildCategoryID = nil
            return
        }

        guard let category = category(by: id), category.parentId == nil else { return }

        selectedParentCategoryID = category.id
        if currentChildCategories.contains(where: { $0.id == selectedChildCategoryID }) == false {
            selectedChildCategoryID = nil
        }
    }

    func handleChildCategorySelection(_ id: UUID?) {
        guard let parentId = selectedParentCategoryID else {
            selectedChildCategoryID = nil
            return
        }

        guard let id else {
            selectedChildCategoryID = nil
            return
        }

        guard let category = category(by: id), category.parentId == parentId else { return }
        selectedChildCategoryID = category.id
    }

    var effectiveSelectedCategoryID: UUID? {
        selectedChildCategoryID ?? selectedParentCategoryID
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
        guard sortingOption.sortingOptionCase != .indexKey else { return nil }
        return sortingOption.toText()
    }
    
    func mapSortingOrderToText(_ sortingOption: SortingOption?) -> String? {
        guard let sortingOption else { return nil }
        guard sortingOption.sortingOptionCase != .indexKey else { return nil }
        return sortingOption.orderToText(isAscending: sortingOption.order == .ascending)
    }
    
    func makeSortOptions() -> [SortingOption] {
        [
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
    
    func makeCategoryFilterOptions(
        from categories: [Category]
    ) -> [FilterMenuInfo.NamedFilterOption] {
        categories
            .sorted { $0.indexKey < $1.indexKey }
            .map { category in
                FilterMenuInfo.NamedFilterOption(id: category.id, title: category.name)
            }
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
    
    func validatedFilterID(
        _ id: UUID?,
        from nameByID: [UUID: String]
    ) -> UUID? {
        guard let id, nameByID[id] != nil else { return nil }
        return id
    }
    
    var currentFilters: [FilterOption] {
        [
            effectiveSelectedCategoryID.map { .category($0) },
            selectedLocationID.map { .location($0) },
            selectedItemStateID.map { .itemState($0) }
        ]
        .compactMap { $0 }
    }
    
    func savePresetBeforePop() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await updatePreset()
                await MainActor.run {
                    self.onNavigation?(.pop)
                }
            } catch {
                await MainActor.run {
                    self.onNavigation?(.showSaveFailureAlert("저장에 실패했습니다."))
                }
            }
        }
    }
    
    func updatePreset() async throws {
        let currentSortingOption = currentSortingOption ?? .indexKey(order: .ascending)
        
        let updatedPreset = ViewPreset(
            id: context.preset.id,
            workspaceId: context.preset.workspaceId,
            name: context.preset.name,
            viewType: currentViewType,
            sortingOption: currentSortingOption,
            filters: currentFilters,
            createdAt: context.preset.createdAt,
            updatedAt: context.preset.updatedAt
        )
        
        let result = await viewPresetUsecase.updateViewPreset(
            id: context.preset.id,
            preset: updatedPreset
        )
        
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}

private extension PresetDetailViewModel {
    static func normalizedSortingOption(_ sortingOption: SortingOption) -> SortingOption? {
        guard sortingOption.sortingOptionCase != .indexKey else { return nil }
        return sortingOption
    }
    
    static func extractCategoryID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .category(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    static func extractLocationID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .location(let id) = filter {
                return id
            }
        }
        return nil
    }
    
    static func extractItemStateID(from filters: [FilterOption]) -> UUID? {
        for filter in filters {
            if case .itemState(let id) = filter {
                return id
            }
        }
        return nil
    }
}
