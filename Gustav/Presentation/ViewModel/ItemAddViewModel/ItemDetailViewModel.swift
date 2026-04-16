//
//  ItemDetailViewModel.swift
//  Gustav
//
//

import Foundation

// 상세 화면 진입 시점에 필요한 고정 데이터 묶음
struct ItemDetailContext {
    let workspaceId: UUID
    let item: Item
}

// 아이템 상세 화면의 입력 처리, 상태 관리, 저장 로직을 담당하는 ViewModel
final class ItemDetailViewModel {

    // MARK: - Dependencies

    private let context: ItemDetailContext
    private let itemUseCase: ItemUsecaseProtocol
    private let workspaceContextUsecase: WorkspaceContextUsecaseProtocol

    init(
        context: ItemDetailContext,
        itemUseCase: ItemUsecaseProtocol,
        workspaceContextUsecase: WorkspaceContextUsecaseProtocol
    ) {
        self.context = context
        self.itemUseCase = itemUseCase
        self.workspaceContextUsecase = workspaceContextUsecase
        configureInitialFormState()
    }

    // MARK: - Form State

    // 화면에서 편집 중인 입력값을 보관하는 폼 상태
    struct FormState {
        // 기본 텍스트 입력값
        var name: String = ""
        var detailName: String = ""
        var priceText: String = ""
        var quantityText: String = ""
        var memo: String = ""
        var purchasePlace: String = ""

        // 구매일 사용 여부 및 날짜/시간 분리 상태
        var isPurchaseDateEnabled: Bool = false
        var purchaseDatePart: Date = Date()
        var purchaseTimePart: Date = Date()

        // 보증 만료일 사용 여부 및 날짜/시간 분리 상태
        var isExpireDateEnabled: Bool = false
        var expireDatePart: Date = Date()
        var expireTimePart: Date = Date()

        // 카테고리 선택 상태
        var selectedParentCategoryId: UUID?
        var selectedParentCategoryName: String?
        var selectedChildCategoryId: UUID?
        var selectedChildCategoryName: String?

        // 아이템 상태 선택 상태
        var selectedItemStateId: UUID?
        var selectedItemStateName: String?

        // 위치 선택 상태
        var selectedLocationId: UUID?
        var selectedLocationName: String?
    }

    // MARK: - Input

    // ViewController에서 전달하는 사용자 이벤트
    enum Input {
        case dismiss
        case viewDidLoad
        case viewDidAppear

        case changeName(String)
        case changeDetailName(String)
        case changePrice(String)
        case changeQuantity(String)

        case changeMemo(String)
        case changePurchasePlace(String)

        case togglePurchaseDate(Bool)
        case changePurchaseDate(Date)
        case changePurchaseTime(Date)

        case toggleExpireDate(Bool)
        case changeExpireDate(Date)
        case changeExpireTime(Date)

        case selectParentCategory(UUID?)
        case selectChildCategory(UUID?)
        case selectItemState(id: UUID?, name: String?)
        case selectLocation(id: UUID?, name: String?)

        case tapSave
    }

    // MARK: - Output

    // ViewController가 화면을 그릴 때 사용하는 출력 모델
    struct Output {
        let workspaceName: String
        let saveButtonEnabled: Bool
        let isSaving: Bool

        let selectedCategoryName: String?
        let selectedSubcategoryName: String?
        let selectedItemStateName: String?
        let selectedLocationName: String?

        let selectedParentCategoryID: UUID?
        let selectedChildCategoryID: UUID?
        let selectedItemStateID: UUID?
        let selectedLocationID: UUID?

        let isPurchaseDateEnabled: Bool
        let isExpireDateEnabled: Bool
        let availableParentCategories: [Category]
        let availableChildCategories: [Category]
        let showsSubcategoryRow: Bool
        let availableItemStates: [ItemState]
        let availableLocations: [Location]
    }

    // MARK: - Route

    // Coordinator 또는 ViewController로 전달할 화면 이동/알림 이벤트
    enum Route {
        case dismiss
        case dismissAfterSave
        case showErrorAlert(String)
    }

    // MARK: - Callbacks

    // 화면 갱신 및 라우팅 전달용 콜백
    var onDisplay: ((Output) -> Void)?
    var onNavigation: ((Route) -> Void)?

    // MARK: - State

    // 현재 편집 중인 상태와 저장 진행 여부
    private var formState = FormState()
    private var isSaving = false
    private var hasLoadedWorkspaceContext = false

    private var workspaceContext: WorkspaceContext?

    // 최초 화면 구성 시 View에 전달할 초기 표시 데이터
    var initialContent: ItemDetailView.Content {
        .init(
            name: formState.name,
            detailName: formState.detailName,
            priceText: formState.priceText,
            quantityText: formState.quantityText,
            memo: formState.memo,
            purchasePlace: formState.purchasePlace,
            purchaseDate: formState.purchaseDatePart,
            purchaseTime: formState.purchaseTimePart,
            isPurchaseDateEnabled: formState.isPurchaseDateEnabled,
            expireDate: formState.expireDatePart,
            expireTime: formState.expireTimePart,
            isExpireDateEnabled: formState.isExpireDateEnabled,
            category: nil,
            subcategory: nil,
            showsSubcategory: false,
            itemState: nil,
            location: nil
        )
    }
}

// MARK: - Public Action

extension ItemDetailViewModel {
    // 외부 입력을 받아 상태 변경 또는 저장 동작으로 연결
    func action(_ input: Input) {
        switch input {
        // 화면 이동
        case .dismiss:
            onNavigation?(.dismiss)

        // 초기 화면 표시
        case .viewDidLoad:
            notifyOutput()
            Task {
                await fetchWorkspaceContextIfNeeded()
            }

        case .viewDidAppear:
            notifyOutput()

        // 텍스트 입력 변경
        case .changeName(let name):
            formState.name = name
            notifyOutput()

        case .changeDetailName(let detailName):
            formState.detailName = detailName
            notifyOutput()

        case .changePrice(let priceText):
            formState.priceText = priceText
            notifyOutput()

        case .changeQuantity(let quantityText):
            formState.quantityText = quantityText
            notifyOutput()

        case .changeMemo(let memo):
            formState.memo = memo
            notifyOutput()

        case .changePurchasePlace(let place):
            formState.purchasePlace = place
            notifyOutput()

        // 구매일 관련 입력 변경
        case .togglePurchaseDate(let isEnabled):
            formState.isPurchaseDateEnabled = isEnabled
            notifyOutput()

        case .changePurchaseDate(let date):
            formState.purchaseDatePart = date
            notifyOutput()

        case .changePurchaseTime(let time):
            formState.purchaseTimePart = time
            notifyOutput()

        // 만료일 관련 입력 변경
        case .toggleExpireDate(let isEnabled):
            formState.isExpireDateEnabled = isEnabled
            notifyOutput()

        case .changeExpireDate(let date):
            formState.expireDatePart = date
            notifyOutput()

        case .changeExpireTime(let time):
            formState.expireTimePart = time
            notifyOutput()

        // 선택형 입력 변경
        case .selectParentCategory(let id):
            handleParentCategorySelection(id)
            notifyOutput()

        case .selectChildCategory(let id):
            handleChildCategorySelection(id)
            notifyOutput()

        case .selectItemState(let id, let name):
            formState.selectedItemStateId = id
            formState.selectedItemStateName = name
            notifyOutput()

        case .selectLocation(let id, let name):
            formState.selectedLocationId = id
            formState.selectedLocationName = name
            notifyOutput()

        // 저장 요청
        case .tapSave:
            Task {
                await handleSave()
            }
        }
    }
}

// MARK: - Private Logic

private extension ItemDetailViewModel {
    // 전달받은 기존 Item 정보를 폼 상태에 반영
    func configureInitialFormState() {
        let item = context.item

        formState.name = item.name
        formState.detailName = item.nameDetail ?? ""
        formState.priceText = item.price.map(String.init) ?? ""
        formState.quantityText = item.quantity.map(String.init) ?? ""
        formState.memo = item.memo ?? ""
        formState.purchasePlace = item.purchasePlace ?? ""
        formState.selectedParentCategoryId = item.categoryId
        formState.selectedItemStateId = item.stateId
        formState.selectedLocationId = item.locationId

        formState.isPurchaseDateEnabled = item.purchaseDate != nil
        formState.purchaseDatePart = item.purchaseDate ?? Date()
        formState.purchaseTimePart = item.purchaseDate ?? Date()

        formState.isExpireDateEnabled = item.warrantyExpireAt != nil
        formState.expireDatePart = item.warrantyExpireAt ?? Date()
        formState.expireTimePart = item.warrantyExpireAt ?? Date()
    }

    func fetchWorkspaceContextIfNeeded() async {
        guard hasLoadedWorkspaceContext == false else { return }

        let result = await workspaceContextUsecase.fetchContext(workspaceId: context.workspaceId)

        switch result {
        case .success(let workspaceContext):
            self.workspaceContext = workspaceContext
            self.hasLoadedWorkspaceContext = true
            configureSelectionsFromWorkspaceContext()
            notifyOutput()

        case .failure:
            onNavigation?(.showErrorAlert("Failed to load category, state, and location data."))
        }
    }

    func configureSelectionsFromWorkspaceContext() {
        configureSelectedCategory(with: context.item.categoryId)

        if let state = workspaceContext?.states.first(where: { $0.id == context.item.stateId }) {
            formState.selectedItemStateId = state.id
            formState.selectedItemStateName = state.name
        }

        if let location = workspaceContext?.locations.first(where: { $0.id == context.item.locationId }) {
            formState.selectedLocationId = location.id
            formState.selectedLocationName = location.name
        }
    }

    // 저장된 categoryId를 부모/자식 카테고리 선택 상태로 복원
    func configureSelectedCategory(with categoryId: UUID?) {
        guard let categoryId, let selectedCategory = category(by: categoryId) else { return }

        if let parentId = selectedCategory.parentId,
           let parentCategory = category(by: parentId) {
            formState.selectedParentCategoryId = parentCategory.id
            formState.selectedParentCategoryName = parentCategory.name
            formState.selectedChildCategoryId = selectedCategory.id
            formState.selectedChildCategoryName = selectedCategory.name
            return
        }

        formState.selectedParentCategoryId = selectedCategory.id
        formState.selectedParentCategoryName = selectedCategory.name
    }

    // 현재 상태를 Output으로 변환하여 화면에 전달
    func notifyOutput() {
        let output = Output(
            workspaceName: workspaceContext?.workspace.name ?? "",
            saveButtonEnabled: isSaveButtonEnabled,
            isSaving: isSaving,
            selectedCategoryName: formState.selectedParentCategoryName,
            selectedSubcategoryName: formState.selectedChildCategoryName,
            selectedItemStateName: formState.selectedItemStateName,
            selectedLocationName: formState.selectedLocationName,
            selectedParentCategoryID: formState.selectedParentCategoryId,
            selectedChildCategoryID: formState.selectedChildCategoryId,
            selectedItemStateID: formState.selectedItemStateId,
            selectedLocationID: formState.selectedLocationId,
            isPurchaseDateEnabled: formState.isPurchaseDateEnabled,
            isExpireDateEnabled: formState.isExpireDateEnabled,
            availableParentCategories: parentCategories,
            availableChildCategories: currentChildCategories,
            showsSubcategoryRow: currentChildCategories.isEmpty == false,
            availableItemStates: workspaceContext?.states ?? [],
            availableLocations: workspaceContext?.locations ?? []
        )

        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }

    // 선택 UI 구성을 위한 카테고리 계산 프로퍼티
    var parentCategories: [Category] {
        workspaceContext?.categories.filter { $0.parentId == nil } ?? []
    }

    var currentChildCategories: [Category] {
        guard let parentId = formState.selectedParentCategoryId else { return [] }
        return workspaceContext?.categories.filter { $0.parentId == parentId } ?? []
    }

    // ID로 카테고리 조회
    func category(by id: UUID) -> Category? {
        workspaceContext?.categories.first(where: { $0.id == id })
    }

    // 부모 카테고리 선택 시 자식 카테고리 유효성까지 함께 정리
    func handleParentCategorySelection(_ id: UUID?) {
        guard let id else {
            formState.selectedParentCategoryId = nil
            formState.selectedParentCategoryName = nil
            formState.selectedChildCategoryId = nil
            formState.selectedChildCategoryName = nil
            return
        }

        guard let category = category(by: id), category.parentId == nil else { return }

        formState.selectedParentCategoryId = category.id
        formState.selectedParentCategoryName = category.name

        let childCategories = workspaceContext?.categories.filter { $0.parentId == category.id } ?? []
        if childCategories.contains(where: { $0.id == formState.selectedChildCategoryId }) == false {
            formState.selectedChildCategoryId = nil
            formState.selectedChildCategoryName = nil
        }
    }

    // 자식 카테고리는 현재 선택된 부모 카테고리 하위인지 검증 후 반영
    func handleChildCategorySelection(_ id: UUID?) {
        guard let parentId = formState.selectedParentCategoryId else {
            formState.selectedChildCategoryId = nil
            formState.selectedChildCategoryName = nil
            return
        }

        guard let id else {
            formState.selectedChildCategoryId = nil
            formState.selectedChildCategoryName = nil
            return
        }

        guard let category = category(by: id), category.parentId == parentId else { return }
        formState.selectedChildCategoryId = category.id
        formState.selectedChildCategoryName = category.name
    }

    // 저장 시에는 자식 카테고리가 있으면 우선 사용하고, 없으면 부모 카테고리를 사용
    var effectiveSelectedCategoryId: UUID? {
        formState.selectedChildCategoryId ?? formState.selectedParentCategoryId
    }

    // 저장 버튼 활성화 가능 여부 계산
    var isSaveButtonEnabled: Bool {
        let trimmedName = formState.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if isSaving { return false }
        if trimmedName.isEmpty { return false }

        if !formState.priceText.isEmpty && parsedPrice == nil {
            return false
        }

        if !formState.quantityText.isEmpty && parsedQuantity == nil {
            return false
        }

        return true
    }

    // 저장 전 검증 에러 종류
    enum ValidationError: Error {
        case emptyName
        case invalidPrice
        case invalidQuantity
    }

    // 문자열 입력값을 실제 저장 타입으로 변환
    var parsedPrice: Int? {
        guard !formState.priceText.isEmpty else { return nil }
        return Int(formState.priceText)
    }

    var parsedQuantity: Int? {
        guard !formState.quantityText.isEmpty else { return nil }
        return Int(formState.quantityText)
    }

    // 분리된 날짜/시간 입력을 하나의 Date로 결합
    var combinedPurchaseDate: Date? {
        guard formState.isPurchaseDateEnabled else { return nil }
        return combine(date: formState.purchaseDatePart, time: formState.purchaseTimePart)
    }

    var combinedExpireDate: Date? {
        guard formState.isExpireDateEnabled else { return nil }
        return combine(date: formState.expireDatePart, time: formState.expireTimePart)
    }

    // 저장 가능한 상태인지 검사
    func validateForm() -> ValidationError? {
        let trimmedName = formState.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            return .emptyName
        }

        if !formState.priceText.isEmpty && parsedPrice == nil {
            return .invalidPrice
        }

        if !formState.quantityText.isEmpty && parsedQuantity == nil {
            return .invalidQuantity
        }

        return nil
    }

    // 검증 실패 메시지 매핑
    func validationMessage(for error: ValidationError) -> String {
        switch error {
        case .emptyName:
            return "Item name is required."
        case .invalidPrice:
            return "Price must be a valid number."
        case .invalidQuantity:
            return "Quantity must be a valid number."
        }
    }

    // 날짜 파트와 시간 파트를 합쳐 최종 Date 생성
    func combine(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        return calendar.date(from: combinedComponents)
    }

    // 검증 -> 저장 상태 반영 -> Item 재구성 -> 업데이트 요청 순서로 저장 수행
    func handleSave() async {
        // 중복 저장 방지
        guard !isSaving else { return }

        // 입력값 검증 실패 시 즉시 종료
        if let validationError = validateForm() {
            let message = validationMessage(for: validationError)
            onNavigation?(.showErrorAlert(message))
            return
        }

        // 저장 중 상태를 화면에 반영
        isSaving = true
        notifyOutput()

        defer {
            isSaving = false
            notifyOutput()
        }

        // 저장 직전 공백 정리 및 optional 값 정규화
        let trimmedName = formState.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetailName = formState.detailName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = formState.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPurchasePlace = formState.purchasePlace.trimmingCharacters(in: .whitespacesAndNewlines)

        let detailName = trimmedDetailName.isEmpty ? nil : trimmedDetailName
        let memo = trimmedMemo.isEmpty ? nil : trimmedMemo
        let purchasePlace = trimmedPurchasePlace.isEmpty ? nil : trimmedPurchasePlace

        // 최신 폼 상태를 기준으로 업데이트할 Item 재구성
        let item = Item(
            id: context.item.id,
            workspaceId: context.workspaceId,
            indexKey: context.item.indexKey,
            name: trimmedName,
            nameDetail: detailName,
            categoryId: effectiveSelectedCategoryId,
            stateId: formState.selectedItemStateId,
            locationId: formState.selectedLocationId,
            purchaseDate: combinedPurchaseDate,
            purchasePlace: purchasePlace,
            warrantyExpireAt: combinedExpireDate,
            price: parsedPrice,
            quantity: parsedQuantity,
            memo: memo,
            createdAt: context.item.createdAt,
            updatedAt: Date()
        )

        // UseCase를 통해 실제 업데이트 요청
        let result = await itemUseCase.updateItem(id: context.item.id, item: item)

        // 저장 결과에 따라 화면 종료 또는 에러 표시
        switch result {
        case .success:
            onNavigation?(.dismissAfterSave)
        case .failure:
            onNavigation?(.showErrorAlert("Failed to update item."))
        }
    }
}
