//
//  ItemAddViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/31/26.
//

import Foundation

// MARK: - ItemAddContext
/// 아이템 추가 화면에 필요한 고정 데이터를 ViewModel에 전달하기 위한 구조
struct ItemAddContext {
    let workspaceId: UUID
    let workspaceName: String
}

// MARK: - ItemAddViewModel
final class ItemAddViewModel {
    
    // MARK: Dependencies
    /// 아이템 추가 화면에 필요한 워크스페이스 고정 데이터
    private let context: ItemAddContext
    
    /// 아이템 생성 유스케이스
    private let itemUseCase: ItemUsecaseProtocol
    private let workspaceContextUsecase: WorkspaceContextUsecaseProtocol
    
    init(
        context: ItemAddContext,
        itemUseCase: ItemUsecaseProtocol,
        workspaceContextUsecase: WorkspaceContextUsecaseProtocol
    ) {
        self.context = context
        self.itemUseCase = itemUseCase
        self.workspaceContextUsecase = workspaceContextUsecase
    }
    
    // MARK: Form State
    /// 아이템 추가 화면에서 사용자가 입력 중인 폼 상태
    /// 화면의 입력 폼 전체 상태
    struct FormState {
        /// 기본 텍스트 입력값
        /// 아이템 이름 (필수)
        var name: String = ""
        
        /// 아이템 상세 이름 (선택)
        var detailName: String = ""
        
        /// 가격 입력 원본 문자열
        var priceText: String = ""
        
        /// 수량 입력 원본 문자열
        var quantityText: String = ""
        
        /// 메모 입력값
        var memo: String = ""
        
        /// 구매처 입력값
        var purchasePlace: String = ""

        /// 구매일 사용 여부 및 날짜/시간 입력 상태
        /// 구매일 사용 여부
        var isPurchaseDateEnabled: Bool = false
        
        /// 구매 날짜 부분
        var purchaseDatePart: Date = Date()
        
        /// 구매 시간 부분
        var purchaseTimePart: Date = Date()

        /// 만료일 사용 여부 및 날짜/시간 입력 상태
        /// 만료일 사용 여부
        var isExpireDateEnabled: Bool = false
        
        /// 만료 날짜 부분
        var expireDatePart: Date = Date()
        
        /// 만료 시간 부분
        var expireTimePart: Date = Date()

        /// 카테고리 선택 상태
        /// 선택된 카테고리 정보
        var selectedParentCategoryId: UUID?
        var selectedParentCategoryName: String?
        var selectedChildCategoryId: UUID?
        var selectedChildCategoryName: String?

        /// 아이템 상태 선택 상태
        /// 선택된 상태 정보
        var selectedItemStateId: UUID?
        var selectedItemStateName: String?

        /// 위치 선택 상태
        /// 선택된 위치 정보
        var selectedLocationId: UUID?
        var selectedLocationName: String?
    }
    
    // MARK: Input
    /// ViewController가 ViewModel에 전달하는 사용자 입력 이벤트
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
    
    // MARK: Output
    /// ViewModel이 ViewController에 전달하는 화면 표시용 상태
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
    
    // MARK: Route
    /// Coordinator 또는 ViewController가 처리할 화면 이동 / 알럿 이벤트
    enum Route {
        case dismiss
        case dismissAfterSave
        case showErrorAlert(String)
    }
    
    // MARK: Callbacks
    /// 화면 표시 상태 전달
    var onDisplay: ((Output) -> Void)?
    
    /// 화면 이동 이벤트 전달
    var onNavigation: ((Route) -> Void)?
    
    // MARK: State
    /// 화면에 표시 중인 현재 입력값 스냅샷
    /// 현재 폼 입력 상태
    private var formState = FormState()
    
    /// 저장 진행 중 여부
    private var isSaving = false
    private var hasLoadedWorkspaceContext = false
    
    /// 현재 워크스페이스에 종속된 참조 데이터
    private var workspaceContext: WorkspaceContext?
}

// MARK: - Public Action
extension ItemAddViewModel {
    /// ViewController에서 전달된 입력 이벤트 처리
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
private extension ItemAddViewModel {
    func fetchWorkspaceContextIfNeeded() async {
        guard hasLoadedWorkspaceContext == false else { return }

        let result = await workspaceContextUsecase.fetchContext(workspaceId: context.workspaceId)

        switch result {
        case .success(let workspaceContext):
            self.workspaceContext = workspaceContext
            self.hasLoadedWorkspaceContext = true
            notifyOutput()

        case .failure:
            onNavigation?(.showErrorAlert("Failed to load category, state, and location data."))
        }
    }

    /// 현재 상태를 Output으로 만들어 ViewController에 전달
    func notifyOutput() {
        let output = Output(
            workspaceName: context.workspaceName,
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

    /// 상위 카테고리만 추려서 반환
    var parentCategories: [Category] {
        workspaceContext?.categories.filter { $0.parentId == nil } ?? []
    }

    /// 현재 선택된 상위 카테고리에 속한 하위 카테고리 목록
    var currentChildCategories: [Category] {
        guard let parentId = formState.selectedParentCategoryId else { return [] }
        return workspaceContext?.categories.filter { $0.parentId == parentId } ?? []
    }

    /// 카테고리 ID로 실제 Category 모델 조회
    func category(by id: UUID) -> Category? {
        workspaceContext?.categories.first(where: { $0.id == id })
    }

    /// 상위 카테고리 선택 처리
    /// - nil이면 상위/하위 선택을 모두 해제
    /// - 유효한 상위 카테고리면 반영
    /// - 기존 하위 카테고리가 새 상위 카테고리 하위에 없으면 초기화
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

    /// 하위 카테고리 선택 처리
    /// - 상위 카테고리가 없으면 선택 불가
    /// - nil이면 하위 카테고리만 해제
    /// - 현재 상위 카테고리의 자식일 때만 반영
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

    /// 저장 시 사용할 최종 카테고리 ID
    /// 하위 카테고리가 선택되어 있으면 우선 사용하고, 없으면 상위 카테고리를 사용
    var effectiveSelectedCategoryId: UUID? {
        formState.selectedChildCategoryId ?? formState.selectedParentCategoryId
    }

    /// 저장 버튼 활성화 여부 계산
    /// - 이름은 필수
    /// - 가격 / 수량은 비어 있으면 허용
    /// - 입력된 경우에만 숫자 변환 가능 여부 검사
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

    /// 저장 직전 상세 검증 에러
    enum ValidationError: Error {
        case emptyName
        case invalidPrice
        case invalidQuantity
    }

    /// 가격 문자열을 Int로 변환
    var parsedPrice: Int? {
        guard !formState.priceText.isEmpty else { return nil }
        return Int(formState.priceText)
    }

    /// 수량 문자열을 Int로 변환
    var parsedQuantity: Int? {
        guard !formState.quantityText.isEmpty else { return nil }
        return Int(formState.quantityText)
    }

    /// 구매 날짜와 시간을 합친 최종 Date
    /// 토글이 꺼져 있으면 nil
    var combinedPurchaseDate: Date? {
        guard formState.isPurchaseDateEnabled else { return nil }
        return combine(date: formState.purchaseDatePart, time: formState.purchaseTimePart)
    }

    /// 만료 날짜와 시간을 합친 최종 Date
    /// 토글이 꺼져 있으면 nil
    var combinedExpireDate: Date? {
        guard formState.isExpireDateEnabled else { return nil }
        return combine(date: formState.expireDatePart, time: formState.expireTimePart)
    }

    /// 저장 직전 상세 검증
    func validateForm() -> ValidationError? {
        // 이름은 공백만 입력된 경우도 비어 있다고 판단
        let trimmedName = formState.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            return .emptyName
        }

        // 숫자 필드는 값이 입력된 경우에만 형식 검사
        if !formState.priceText.isEmpty && parsedPrice == nil {
            return .invalidPrice
        }

        if !formState.quantityText.isEmpty && parsedQuantity == nil {
            return .invalidQuantity
        }

        return nil
    }

    /// 검증 에러를 사용자 표시용 메시지로 변환
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

    /// 날짜 부분과 시간 부분을 합쳐 하나의 Date로 변환
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

    /// 저장 처리
    /// 1. 중복 저장 방지
    /// 2. 상세 검증
    /// 3. 로딩 시작
    /// 4. FormState -> Item 변환
    /// 5. Usecase 호출
    /// 6. 성공 / 실패 라우팅
    func handleSave() async {
        // 중복 저장 방지
        guard !isSaving else { return }

        // 저장 전 최종 검증 실패 시 에러 메시지 표시
        if let validationError = validateForm() {
            let message = validationMessage(for: validationError)
            onNavigation?(.showErrorAlert(message))
            return
        }

        // 저장 시작 상태를 화면에 반영
        isSaving = true
        notifyOutput()

        // 저장 성공/실패와 관계없이 종료 시 로딩 상태 해제
        defer {
            isSaving = false
            notifyOutput()
        }

        // 문자열 정리: 공백 제거 후 빈 문자열은 nil로 정규화
        let trimmedName = formState.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetailName = formState.detailName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = formState.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPurchasePlace = formState.purchasePlace.trimmingCharacters(in: .whitespacesAndNewlines)

        let detailName = trimmedDetailName.isEmpty ? nil : trimmedDetailName
        let memo = trimmedMemo.isEmpty ? nil : trimmedMemo
        let purchasePlace = trimmedPurchasePlace.isEmpty ? nil : trimmedPurchasePlace

        // FormState를 실제 저장 타입으로 변환
        // 숫자 / 날짜 변환
        let price = parsedPrice
        let quantity = parsedQuantity
        let purchaseDate = combinedPurchaseDate
        let expireDate = combinedExpireDate

        // 생성 대상 워크스페이스 식별값과 생성 시각 고정
        // item.workspaceId와 createItem 파라미터의 workspaceId가 달라지지 않도록
        // 하나의 상수로 묶어서 동일한 값을 사용
        let targetWorkspaceId = context.workspaceId
        let now = Date()

        let item = Item(
            id: UUID(),
            workspaceId: targetWorkspaceId,
            indexKey: 0,
            name: trimmedName,
            nameDetail: detailName,
            categoryId: effectiveSelectedCategoryId,
            stateId: formState.selectedItemStateId,
            locationId: formState.selectedLocationId,
            purchaseDate: purchaseDate,
            purchasePlace: purchasePlace,
            warrantyExpireAt: expireDate,
            price: price,
            quantity: quantity,
            memo: memo,
            createdAt: now,
            updatedAt: now
        )

        // UseCase를 통해 아이템 생성 요청
        let result = await itemUseCase.createItem(workspaceId: targetWorkspaceId, item: item)

        // 결과에 따라 화면 종료 또는 에러 알럿 표시
        switch result {
        case .success:
            onNavigation?(.dismissAfterSave)
        case .failure:
            onNavigation?(.showErrorAlert("Failed to create item."))
        }
    }
}
