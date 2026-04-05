//
//  WorkspaceViewModel.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//
import Foundation

// MARK: - WorkspaceViewModel
final class WorkspaceViewModel {
    // MARK: - Usecase
    private let workspace: Workspace
    private let itemUsecase: ItemUsecaseProtocol
    private let itemQueryUsecase: ItemQueryUsecaseProtocol
    private let itemReferenceUsecase: ItemReferenceUsecaseProtocol
    
    // MARK: - Query
    private var query: ItemQuery
    
    // MARK: - Initializer
    init(workspace: Workspace, itemUsecase: ItemUsecaseProtocol, itemQueryUsecase: ItemQueryUsecaseProtocol, itemReferenceUsecase: ItemReferenceUsecaseProtocol) {
        self.workspace = workspace
        self.itemUsecase = itemUsecase
        self.itemQueryUsecase = itemQueryUsecase
        self.itemReferenceUsecase = itemReferenceUsecase
        self.query = ItemQuery(sortOption: .indexKey(order: .ascending), filters: [], searchText: nil)
    }
    
    // MARK: - Pagination
    private var offset: Int = 0
    private let limit: Int = 20
    private var isLastPage: Bool = false
    
    // MARK: - State
    private var itemReferences: [ItemReference] = []
    private var itemCellDatas: [WorkspaceItemCellData] = []
    private var queryProperties: Set<ItemProperty> = []
    private var tableViewAction: TableViewAction = .reloadData
    private var isLoading: LoadingState = .notLoading
    
    // MARK: - Input
    enum Input {
        case dismiss
        case viewDidLoad
        case viewDidAppear
        
        case loadNextPage
        case tapExpandButton(UUID)
        case tapEditButton(UUID)
        case tapDeleteButton(WorkspaceItemCellData)
        case itemDeleteConfirmed(UUID)
        case queryChanged(ItemQuery)
        case itemReordered([UUID])
        case toWorkspaceSettings
        case toAddItem
    }
    
    // MARK: - Output
    struct Output {
        let workspaceName: String
        let action: TableViewAction
        let isLoading: LoadingState
    }
    
    // MARK: - Route
    enum Route {
        case dismiss
        case showWorkspaceSettings
        case showAddItem
        case showEditItem(UUID)
        case showAlertForDeleteItemConfirmation(WorkspaceItemCellData)
        case showAlertToNoticeQueryFailure
        case showAlertForDeleteItemFailure
    }
    
    // MARK: - Loading State
    // 로딩 상태의 종류를 구별하기 위한 열거형
    enum LoadingState {
        case loading(for: String)
        case notLoading
    }
    
    // MARK: - TableView Actions
    // ViewController의 테이블 뷰에서 Output을 처리하기 위한 방식 명시
    enum TableViewAction {
        case reloadData
        case reloadCell(Int)
        case insertRows((Int, Int))
        case deleteRow(Int)
    }
    
    // MARK: - Closures
    // Output 변경 시 VC에 전달하여 화면 업데이트
    var onDisplay: ((Output) -> Void)?
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
}

// MARK: - 외부 호출 메서드
extension WorkspaceViewModel {
    // Input 처리 메서드
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            onNavigation?(.dismiss)
        case .viewDidLoad:
            break
        case .viewDidAppear:
            Task {
                // 테스트 추가
//                self.queryProperties = [.category, .price]
                await fetchItems()
            }
        case .loadNextPage:
            Task {
                await loadNextPage()
            }
        case .tapExpandButton(let id):
            handleExpandButtonTapped(for: id)
        case .tapEditButton(let id):
            onNavigation?(.showEditItem(id))
        case .tapDeleteButton(let cellData):
            onNavigation?(.showAlertForDeleteItemConfirmation(cellData))
        case .itemDeleteConfirmed(let id):
            Task {
                await handleDeleteItemConfirmed(for: id)
            }
        case .queryChanged(let query):
            Task {
                await handleQueryChanged(to: query)
            }
        case .itemReordered(let order):
            handleItemReordered(to: order)
        case .toWorkspaceSettings:
            onNavigation?(.showWorkspaceSettings)
        case .toAddItem:
            onNavigation?(.showAddItem)
        }
    }
    // 테이블 뷰에 표시할 셀 데이터 배열 반환 계산 속성
    var tableViewCellDatas: [WorkspaceItemCellData] {
        self.itemCellDatas
    }
}

// MARK: - Private Logic
private extension WorkspaceViewModel {
    // 현재 쿼리 및 페이지 정보를 이용하여 아이템 불러오기
    func queryItems() async {
        let pagination = Pagination(offset: self.offset, limit: self.limit)
        let result = await itemQueryUsecase.queryItems(workspaceId: self.workspace.id, query: self.query, pagination: pagination)
        switch result {
        case .success(let items):
            if items.count < limit {
                isLastPage = true
            }
            // 다음 페이지를 불러오는 경우
            switch tableViewAction {
            case .insertRows:
                // 페이지 정보를 저장
                tableViewAction = .insertRows((offset, offset + items.count))
            default:
                break
            }
            offset += items.count
            // 불러온 아이템 정보로 ItemReference 배열 생성
            await createItemReferences(of: items)
        case .failure:
            isLoading = .notLoading
            notifyOutput()
            onNavigation?(.showAlertToNoticeQueryFailure)
        }
    }
    // 처음으로 아이템 불러오기
    func fetchItems() async {
        // 페이지 정보 및 저장 중인 아이템 정보 초기화
        self.offset = 0
        self.isLastPage = false
        itemReferences.removeAll()
        itemCellDatas.removeAll()
        // 로딩 상태 반영
        isLoading = .loading(for: "Loading Items...")
        notifyOutput()
        
        tableViewAction = .reloadData
        await queryItems()
    }
    // 다음 페이지 불러오기
    func loadNextPage() async {
        // 마지막 페이지가 아니면 다음 페이지 로드
        guard !isLastPage else { return }
        
        tableViewAction = .insertRows((0, 0))
        await queryItems()
    }
    // 특정 아이템 셀 확장 버튼 선택 이벤트 처리
    func handleExpandButtonTapped(for id: UUID) {
        // 확장 버튼을 누른 아이템 탐색
        guard let index = itemCellDatas.firstIndex(where: { $0.id == id }) else { return }
        // 해당 아이템의 확장 여부 변경
        itemCellDatas[index].isExpanded.toggle()
        tableViewAction = .reloadCell(index)
        notifyOutput()
    }
    // 아이템 삭제 이벤트 처리
    func handleDeleteItemConfirmed(for id: UUID) async {
        // 로딩 상태 표시
        isLoading = .loading(for: "Deleting Item...")
        notifyOutput()
        
        // 서버에서 아이템 삭제
        let result = await itemUsecase.deleteItem(id: id)
        switch result {
        case .success:
            break
        case .failure:
            onNavigation?(.showAlertForDeleteItemFailure)
            return
        }
        
        // 뷰 모델에서 아이템 삭제
        self.offset -= 1
        itemReferences.removeAll(where: { $0.item.id == id })
        guard let index = itemCellDatas.firstIndex(where: { $0.id == id }) else { return }
        itemCellDatas.removeAll(where: { $0.id == id })
        // 테이블 뷰에서 아이템 Row 삭제
        if itemCellDatas.isEmpty {
            tableViewAction = .reloadData
        } else {
            tableViewAction = .deleteRow(index)
        }
        isLoading = .notLoading
        notifyOutput()
    }
    // 쿼리 조건 변경 이벤트 처리
    func handleQueryChanged(to query: ItemQuery) async {
        // 저장 중인 쿼리 변경
        self.query = query
        // 저장 중인 쿼리 속성 변경
        self.queryProperties = getQueryProperties(from: query)
        // 새로운 쿼리를 이용하여 아이템 불러오기
        await fetchItems()
    }
    func handleItemReordered(to order: [UUID]) {
        // 추후 구현
    }
    // 현재 상태를 VC에 전달하는 메서드
    func notifyOutput() {
        let output = Output(
            workspaceName: workspace.name,
            action: tableViewAction,
            isLoading: isLoading
        )
        
        // Main Thread에서 UI 업데이트
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}

// MARK: - Builder Methods
private extension WorkspaceViewModel {
    // 쿼리를 실행하여 불러온 아이템 정보로 ItemReference 배열 생성
    func createItemReferences(of items: [Item]) async {
        let result = await itemReferenceUsecase.createItemReferences(workspaceId: self.workspace.id, items: items)
        switch result {
        // 성공 시 기존 Item Reference 배열에 추가
        case .success(let references):
            itemReferences.append(contentsOf: references)
            // Item Cell Data 배열 생성
            createItemCellDatas(of: references)
        case .failure:
            isLoading = .notLoading
            notifyOutput()
            onNavigation?(.showAlertToNoticeQueryFailure)
        }
    }
    // 현재 저장된 ItemReference 배열을 이용하여 Item Cell Data 배열 생성
    func createItemCellDatas(of references: [ItemReference]) {
        let cellDatas = references.map {
            let properties = self.getBaseAndExpandedProperties(reference: $0, queryProperties: self.queryProperties)
            return WorkspaceItemCellData(id: $0.item.id, indexKey: $0.item.indexKey, name: $0.item.name, updatedAt: $0.item.updatedAt.forItemProperty(), baseProperties: properties.0, expandedProperties: properties.1, isExpanded: false)
        }
        // 저장 중인 Item Cell Data 배열에 추가
        itemCellDatas.append(contentsOf: cellDatas)
        // 로딩 상태 반영
        isLoading = .notLoading
        // 화면 표시
        notifyOutput()
    }
    // ItemQuery로부터 queryProperties를 얻는 메서드
    func getQueryProperties(from query: ItemQuery) -> Set<ItemProperty> {
        // 강조 속성을 저장할 배열
        var properties: Set<ItemProperty> = []
        // 정렬 조건 검사
        if let sortOption = query.sortOption {
            switch sortOption {
            case .name, .indexKey, .createdAt, .updatedAt:
                break
            default:
                guard let property = ItemProperty.from(sortingOption: sortOption) else { break }
                properties.insert(property)
            }
        }
        // 필터 조건 검사
        query.filters.forEach {
            properties.insert(ItemProperty.from(filterOption: $0))
        }
        // 쿼리에 적용된 정렬 및 필터 조건들을 강조 속성으로 반환
        return properties
    }
    
    // ItemReference와 현재 query 정보를 이용하여 Item Cell Data에 필요한 속성 배열을 얻는 메서드
    func getBaseAndExpandedProperties(reference: ItemReference, queryProperties: Set<ItemProperty>) -> ([WorkspaceItemPropertyData], [WorkspaceItemPropertyData]) {
        let item = reference.item
        // 강조 속성 배열
        var baseProperties: [WorkspaceItemPropertyData] = []
        // 일반 속성 배열
        var expandedProperties: [WorkspaceItemPropertyData] = []
        
        // 이름 상세
        if let nameDetail = item.nameDetail {
            if queryProperties.contains(.nameDetail) {
                baseProperties.append(WorkspaceItemPropertyData(property: .nameDetail, value: nameDetail, color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .nameDetail, value: nameDetail, color: nil, isHighlighted: false))
            }
        }
        // 카테고리
        if let category = reference.category {
            if queryProperties.contains(.category) {
                baseProperties.append(WorkspaceItemPropertyData(property: .category, value: category.name, color: category.color, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .category, value: category.name, color: category.color, isHighlighted: false))
            }
        }
        // 아이템 상태
        if let state = reference.state {
            if queryProperties.contains(.state) {
                baseProperties.append(WorkspaceItemPropertyData(property: .state, value: state.name, color: state.color, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .state, value: state.name, color: state.color, isHighlighted: false))
            }
        }
        // 장소
        if let location = reference.location {
            if queryProperties.contains(.location) {
                baseProperties.append(WorkspaceItemPropertyData(property: .location, value: location.name, color: location.color, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .location, value: location.name, color: location.color, isHighlighted: false))
            }
        }
        // 구매일
        if let purchaseDate = item.purchaseDate {
            if queryProperties.contains(.purchaseDate) {
                baseProperties.append(WorkspaceItemPropertyData(property: .purchaseDate, value: purchaseDate.forItemProperty(), color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .purchaseDate, value: purchaseDate.forItemProperty(), color: nil, isHighlighted: false))
            }
        }
        // 구매처
        if let purchasePlace = item.purchasePlace {
            if queryProperties.contains(.purchasePlace) {
                baseProperties.append(WorkspaceItemPropertyData(property: .purchasePlace, value: purchasePlace, color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .purchasePlace, value: purchasePlace, color: nil, isHighlighted: false))
            }
        }
        // 보증 만료일
        if let warrantyExpireAt = item.warrantyExpireAt {
            if queryProperties.contains(.warrantyExpireAt) {
                baseProperties.append(WorkspaceItemPropertyData(property: .warrantyExpireAt, value: warrantyExpireAt.forItemProperty(), color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .warrantyExpireAt, value: warrantyExpireAt.forItemProperty(), color: nil, isHighlighted: false))
            }
        }
        // 가격
        if let price = item.price {
            if queryProperties.contains(.price) {
                baseProperties.append(WorkspaceItemPropertyData(property: .price, value: "\(price)", color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .price, value: "\(price)", color: nil, isHighlighted: false))
            }
        }
        // 수량
        if let quantity = item.quantity {
            if queryProperties.contains(.quantity) {
                baseProperties.append(WorkspaceItemPropertyData(property: .quantity, value: "\(quantity)", color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .quantity, value: "\(quantity)", color: nil, isHighlighted: false))
            }
        }
        // 메모
        if let memo = item.memo {
            if queryProperties.contains(.memo) {
                baseProperties.append(WorkspaceItemPropertyData(property: .memo, value: memo, color: nil, isHighlighted: true))
            } else {
                expandedProperties.append(WorkspaceItemPropertyData(property: .memo, value: memo, color: nil, isHighlighted: false))
            }
        }
        return (baseProperties, expandedProperties)
    }
}

// MARK: - Date + Extensions
extension Date {
    // 아이템 속성에서 사용할 날짜 및 시간 문자열로 변환
    func forItemProperty() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        return formatter.string(from: self)
    }
}
