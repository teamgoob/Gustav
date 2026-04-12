//
//  PresetDetailViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import Foundation

// MARK: - PresetDetailContext
struct PresetDetailContext {
    let workspaceId: UUID
    let presetId: UUID
}

// MARK: - PresetDetailViewModel
final class PresetDetailViewModel {

    // MARK: - Input
    enum Input {
        case viewDidLoad
        case didTapBack
        case changeName(String)
        case deletePreset
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
            let color: TagColor?
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
        case pop
        case showErrorAlert(String)
    }

    // MARK: - Closures
    var onDisplay: ((Output) -> Void)?
    var onFilterMenuChanged: ((FilterMenuInfo) -> Void)?
    var onNavigation: ((Route) -> Void)?

    // MARK: - Properties
    private let viewPresetUsecase: ViewPresetUsecaseProtocol
    private let workspaceContextUsecase: WorkspaceContextUsecaseProtocol
    private let context: PresetDetailContext

    private var preset: ViewPreset
    private var workspaceName: String = ""
    private var categories: [Category] = []
    private var categoryNameByID: [UUID: String] = [:]
    private var locationNameByID: [UUID: String] = [:]
    private var itemStateNameByID: [UUID: String] = [:]
    private var locationColorByID: [UUID: TagColor] = [:]
    private var itemStateColorByID: [UUID: TagColor] = [:]

    private var hasLoadedDetailContext = false
    private var hasLoadedPreset = false

    private var currentViewType: Int
    private var currentSortingOption: SortingOption?
    private var selectedParentCategoryID: UUID?
    private var selectedChildCategoryID: UUID?
    private var selectedLocationID: UUID?
    private var selectedItemStateID: UUID?

    // MARK: - Init
    init(
        context: PresetDetailContext,
        viewPresetUsecase: ViewPresetUsecaseProtocol,
        workspaceContextUsecase: WorkspaceContextUsecaseProtocol
    ) {
        let fallbackPreset = Self.makeFallbackPreset(
            workspaceId: context.workspaceId,
            presetId: context.presetId
        )

        self.viewPresetUsecase = viewPresetUsecase
        self.workspaceContextUsecase = workspaceContextUsecase
        self.context = context
        self.preset = fallbackPreset
        self.currentViewType = fallbackPreset.viewType
        self.currentSortingOption = Self.normalizedSortingOption(fallbackPreset.sortingOption)
        self.selectedLocationID = Self.extractLocationID(from: fallbackPreset.filters)
        self.selectedItemStateID = Self.extractItemStateID(from: fallbackPreset.filters)
        configureSelectionState(from: fallbackPreset)
    }
}

// MARK: - External Methods
extension PresetDetailViewModel {
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            notifyOutput()
            Task {
                await fetchDetailContextIfNeeded()
            }

        case .didTapBack:
            guard hasLoadedPreset else {
                onNavigation?(.pop)
                return
            }
            savePresetBeforePop()

        case .changeName(let name):
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedName.isEmpty == false else {
                onNavigation?(.showErrorAlert("프리셋 이름을 입력해주세요."))
                return
            }

            preset = ViewPreset(
                id: preset.id,
                workspaceId: preset.workspaceId,
                name: trimmedName,
                viewType: preset.viewType,
                sortingOption: preset.sortingOption,
                filters: preset.filters,
                createdAt: preset.createdAt,
                updatedAt: preset.updatedAt
            )
            notifyOutput()

            Task { [weak self] in
                await self?.updatePresetName()
            }

        case .deletePreset:
            Task { [weak self] in
                await self?.deletePreset()
            }

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
            selectedLocationID = validatedFilterID(id, from: locationNameByID)
            notifyOutput()
            notifyFilterMenu()

        case .selectItemStateFilter(let id):
            selectedItemStateID = validatedFilterID(id, from: itemStateNameByID)
            notifyOutput()
            notifyFilterMenu()
        }
    }
}

// MARK: - Private Logic
private extension PresetDetailViewModel {
    func fetchDetailContextIfNeeded() async {
        guard hasLoadedDetailContext == false else { return }

        async let fetchedPresets = viewPresetUsecase.fetchViewPresets(workspaceId: context.workspaceId)
        async let fetchedWorkspaceContext = workspaceContextUsecase.fetchContext(workspaceId: context.workspaceId)

        let (presetResult, workspaceContextResult) = await (fetchedPresets, fetchedWorkspaceContext)

        applyWorkspaceContextResult(workspaceContextResult)
        applyPresetResult(presetResult)
        hasLoadedDetailContext = true

        notifyOutput()
        notifyFilterMenu()
    }

    func applyPresetResult(_ result: DomainResult<[ViewPreset]>) {
        switch result {
        case .success(let presets):
            if let loadedPreset = presets.first(where: { $0.id == context.presetId }) {
                preset = loadedPreset
                hasLoadedPreset = true
            }
        case .failure:
            break
        }

        currentViewType = preset.viewType
        currentSortingOption = Self.normalizedSortingOption(preset.sortingOption)
        selectedLocationID = Self.extractLocationID(from: preset.filters)
        selectedItemStateID = Self.extractItemStateID(from: preset.filters)
        configureSelectionState(from: preset)
    }

    func applyWorkspaceContextResult(_ result: DomainResult<WorkspaceContext>) {
        switch result {
        case .success(let workspaceContext):
            workspaceName = workspaceContext.workspace.name
            categories = workspaceContext.categories
            categoryNameByID = Dictionary(
                uniqueKeysWithValues: workspaceContext.categories.map { ($0.id, $0.name) }
            )
            locationNameByID = Dictionary(
                uniqueKeysWithValues: workspaceContext.locations.map { ($0.id, $0.name) }
            )
            locationColorByID = Dictionary(
                uniqueKeysWithValues: workspaceContext.locations.map { ($0.id, $0.color) }
            )
            itemStateNameByID = Dictionary(
                uniqueKeysWithValues: workspaceContext.states.map { ($0.id, $0.name) }
            )
            itemStateColorByID = Dictionary(
                uniqueKeysWithValues: workspaceContext.states.map { ($0.id, $0.color) }
            )

        case .failure:
            workspaceName = ""
            categories = []
            categoryNameByID = [:]
            locationNameByID = [:]
            itemStateNameByID = [:]
            locationColorByID = [:]
            itemStateColorByID = [:]
        }
    }

    func configureSelectionState(from preset: ViewPreset) {
        selectedParentCategoryID = nil
        selectedChildCategoryID = nil

        let selectedCategoryID = Self.extractCategoryID(from: preset.filters)
        if let selectedCategoryID,
           let category = categories.first(where: { $0.id == selectedCategoryID }) {
            if let parentId = category.parentId {
                selectedParentCategoryID = parentId
                selectedChildCategoryID = category.id
            } else {
                selectedParentCategoryID = category.id
            }
        }
    }

    func notifyOutput() {
        let output = Output(
            title: preset.name,
            workspaceName: workspaceName,
            viewType: mapViewTypeToText(currentViewType),
            sortingOption: mapSortingOptionToText(currentSortingOption),
            sortingOrder: mapSortingOrderToText(currentSortingOption),
            category: selectedParentCategoryID.flatMap { categoryNameByID[$0] },
            subcategory: selectedChildCategoryID.flatMap { categoryNameByID[$0] },
            showsSubcategory: currentChildCategories.isEmpty == false,
            location: selectedLocationID.flatMap { locationNameByID[$0] },
            itemStatus: selectedItemStateID.flatMap { itemStateNameByID[$0] }
        )

        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }

    func notifyFilterMenu() {
        let menu = FilterMenuInfo(
            viewTypeOptions: [
                FilterMenuInfo.ViewTypeOption(id: 0, title: "Basic")
            ],
            sortOptions: makeSortOptions(),
            parentCategoryFilters: makeCategoryFilterOptions(from: parentCategories),
            childCategoryFilters: makeCategoryFilterOptions(from: currentChildCategories),
            locationFilters: makeNamedFilterOptions(from: locationNameByID, colorByID: locationColorByID),
            itemStateFilters: makeNamedFilterOptions(from: itemStateNameByID, colorByID: itemStateColorByID),
            currentViewType: currentViewType,
            currentSortOption: currentSortingOption,
            currentParentCategoryID: selectedParentCategoryID,
            currentChildCategoryID: selectedChildCategoryID,
            currentLocationID: selectedLocationID,
            currentItemStateID: selectedItemStateID
        )

        DispatchQueue.main.async {
            self.onFilterMenuChanged?(menu)
        }
    }

    var parentCategories: [Category] {
        categories.filter { $0.parentId == nil }
    }

    var currentChildCategories: [Category] {
        guard let parentId = selectedParentCategoryID else { return [] }
        return categories.filter { $0.parentId == parentId }
    }

    func category(by id: UUID) -> Category? {
        categories.first(where: { $0.id == id })
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
                FilterMenuInfo.NamedFilterOption(
                    id: category.id,
                    title: category.name,
                    color: category.color
                )
            }
    }

    func makeNamedFilterOptions(
        from nameByID: [UUID: String],
        colorByID: [UUID: TagColor]
    ) -> [FilterMenuInfo.NamedFilterOption] {
        nameByID
            .sorted { $0.value < $1.value }
            .map { key, value in
                FilterMenuInfo.NamedFilterOption(
                    id: key,
                    title: value,
                    color: colorByID[key]
                )
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
                    self.onNavigation?(.showErrorAlert("저장에 실패했습니다."))
                }
            }
        }
    }

    func updatePresetName() async {
        do {
            try await updatePreset()
        } catch {
            await MainActor.run {
                self.onNavigation?(.showErrorAlert("프리셋 이름 변경에 실패했습니다."))
            }
        }
    }

    func deletePreset() async {
        let result = await viewPresetUsecase.deleteViewPreset(id: preset.id)

        switch result {
        case .success:
            await MainActor.run {
                self.onNavigation?(.pop)
            }
        case .failure:
            await MainActor.run {
                self.onNavigation?(.showErrorAlert("프리셋 삭제에 실패했습니다."))
            }
        }
    }

    func updatePreset() async throws {
        let currentSortingOption = currentSortingOption ?? .indexKey(order: .ascending)

        let updatedPreset = ViewPreset(
            id: preset.id,
            workspaceId: preset.workspaceId,
            name: preset.name,
            viewType: currentViewType,
            sortingOption: currentSortingOption,
            filters: currentFilters,
            createdAt: preset.createdAt,
            updatedAt: preset.updatedAt
        )

        let result = await viewPresetUsecase.updateViewPreset(
            id: preset.id,
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
    static func makeFallbackPreset(workspaceId: UUID, presetId: UUID) -> ViewPreset {
        ViewPreset(
            id: presetId,
            workspaceId: workspaceId,
            name: "",
            viewType: 0,
            sortingOption: .indexKey(order: .ascending),
            filters: [],
            createdAt: nil,
            updatedAt: nil
        )
    }

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
