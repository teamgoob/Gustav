//
//  CategoryDetailViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/24/26.
//
import Foundation

final class CategoryDetailViewModel {
    // Category
    private var category: Category
    
    // All Categories
    private var allCategories: [Category] = [] {
        didSet {
            emit(.changedParentCategory)
        }
    }
    // TagColorCases를 배열로 보관
    private let colors = TagColor.allCases
    
    // 선택한 TagColor case를 보관
    private var selectedColor: TagColor
    
    // Items
    private var items: [Item] = [] {
        didSet {
            print(items.count)
        }
    }
    
    // Usecases
    private let itemQueryUseCase: ItemQueryUsecaseProtocol
    private let categoryUseCase: CategoryUsecaseProtocol
    
    // VC가 구독(바인딩)할 콜백
    var onStateChange: ((State) -> Void)?
    
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
    
    // 테스크 리모트
    var taskRemote: Task<Void, Error>?
    
    // MARK: - Init
    init(category: Category, categoryUsecase: CategoryUsecaseProtocol, itemQueryUsecase: ItemQueryUsecaseProtocol) {
        self.category = category
        self.selectedColor = category.color
        self.categoryUseCase = categoryUsecase
        self.itemQueryUseCase = itemQueryUsecase
    }
    
    // 다음 화면 경로
    enum Route {
        case startChangeName
        case reFetchCategoryList
        case delete
        case showErrorAlert(String)
    }
    
    // 상태 전달
    enum State {
        case fetchedItems
        case changeTagColor
        case changeName(String)
        case changedParentCategory
        case delete
    }
    
    // 상태 전달 메서드
    func emit(_ state: State) {
        self.onStateChange?(state)
    }
    
    // MARK: - VC 혹은 Coordinator에서 전달 받을 요청 케이스
    enum Input {
        case viewDidLoad
        case didChangeTagColor(TagColor)
        case startChangeName
        case changedNameButton(String)
        case didTappedDeleteButton
        case changedParentCategory(UUID?)
    }
    
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.fetchItems()
                await self.fetchCategories()
                emit(.fetchedItems)
            }
        case .didChangeTagColor(let tagColor):
            self.selectedColor = tagColor
            emit(.changeTagColor)
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.changeCategoryColor(tagColor)
                onNavigation?(.reFetchCategoryList)
            }
        case .startChangeName:
            onNavigation?(.startChangeName)
        case .changedNameButton(let name):
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.updateCategoryName(name)
                onNavigation?(.reFetchCategoryList)
            }
        case .didTappedDeleteButton:
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.deleteCategory()
                onNavigation?(.delete)
            }
        case .changedParentCategory(let parentId):
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.changeParentCategory(parentId)
            }
        }
    }
    
    // Category Title 리턴
    func getCategoryTitle() -> String {
        category.name
    }
    
    // Parent Category Title(Name) return
    func getParentCategoryTitle() -> String {
        guard let parentId = self.category.parentId else {
            return "none"
        }
        return self.allCategories.first(where: { $0.id == parentId })?.name ?? "none"
    }
    
    // ParentCategoryUUID 리턴
    func getParentCategoryUUID() -> UUID? {
        guard let parentId = self.category.parentId else {
            return nil
        }
        return parentId
    }
    
    
    // Categories Array(self.category & self.category를 부모카테고리로 지정한 카테고리 제외)
    func getAllCategories() -> [Category] {
        var allCategories = self.allCategories
        
        // 해당 워크스페이스의 카테고리 중 지금 소유하고 있는 카테고리는 제거
        allCategories.removeAll { $0.id == self.category.id }
        
        // 지금 소유하고 있는 카테고리를 상위 카테고리로 지정한 카테고리는 제거
        allCategories.removeAll { $0.parentId == self.category.id }
        
        return allCategories
    }
    
    // TableView DataSource: 사용할 아이템 갯수
    func numberOfRows() -> Int {
        items.count
    }
    
    // TableView DataSource: TableView Cell에서 사용할 아이템
    func cellForRowAt(index: Int) -> Item {
        self.items[index]
    }
    
    // CollectionView DataSource
    func numberOfItems() -> Int {
        self.colors.count
    }
    
    // CollectionView DataSource
    func cellForItemAt(index: Int) -> TagColor {
        self.colors[index]
    }
    
    // CollectionView Delegate
    func getSelectedTagColor() -> TagColor {
        self.selectedColor
    }
    
    // MARK: - Deinit
    deinit {
        print("CategoryDetailViewModel deinit")
    }
    
}

// Data Layer 사용
private extension CategoryDetailViewModel {
    // 아이템 쿼리
    private func fetchItems() async {
        // 쿼리 조건 생성
        let itemQuery = ItemQuery(
            sortOption: .createdAt(order: .ascending),
            filters: [.category(category.id)],
            searchText: nil
        )
        
        // Fetch
        let reult = await itemQueryUseCase
            .queryItems(
                workspaceId: self.category.workspaceId,
                query: itemQuery,
                pagination: nil
            )
        
        switch reult {
        case .success(let items):
            self.items = items
            emit(.fetchedItems)
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 카테고리 이름 변경
    private func updateCategoryName(_ name: String) async {
        let updatedCategory = Category(
            id: category.id,
            workspaceId: category.workspaceId,
            parentId: category.parentId,
            indexKey: category.indexKey,
            name: name,
            color: category.color
        )
        
        let result = await categoryUseCase.updateCategory(
            id: category.id,
            category: updatedCategory
        )
        
        switch result {
            case .success:
            self.category = updatedCategory
            emit(.changeName(name))
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 카테고리 테그 컬러 변경
    private func changeCategoryColor(_ tagColor: TagColor) async {
        let updatedCategory = Category(
            id: category.id,
            workspaceId: category.workspaceId,
            parentId: category.parentId,
            indexKey: category.indexKey,
            name: category.name,
            color: tagColor
        )
        
        let result = await categoryUseCase.updateCategory(
            id: category.id,
            category: updatedCategory
        )
        
        switch result {
            case .success:
            self.category = updatedCategory
            emit(.changeTagColor)
        case .failure(let error):
            self.selectedColor = category.color
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 부모카테고리 변경
    private func changeParentCategory(_ parentCategoryId: UUID?) async {
        let updatedCategory = Category(
            id: self.category.id,
            workspaceId: self.category.workspaceId,
            parentId: parentCategoryId,
            indexKey: self.category.indexKey,
            name: self.category.name,
            color: self.category.color
        )
        
        let result = await categoryUseCase.updateCategory(
            id: category.id,
            category: updatedCategory
        )
        
        switch result {
            case .success:
            self.category = updatedCategory
            emit(.changedParentCategory)
            self.onNavigation?(.reFetchCategoryList)
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 전체 카테고리 가져오기
    private func fetchCategories() async {
        let result = await categoryUseCase.fetchCategories(workspaceId: category.workspaceId)
        switch result {
        case .success(var categories):
            if let myIndex = categories.firstIndex(where: { $0.id == self.category.id }) {
                categories.remove(at: myIndex)
            }
            self.allCategories = categories
        case .failure:
            onNavigation?(.showErrorAlert("Failed to get Parent category"))
        }
    }
    
    // 카테고리 삭제
    private func deleteCategory() async {
        let result = await categoryUseCase.deleteCategory(id: self.category.id, workspaceId: self.category.workspaceId)
        switch result {
        case .success:
            emit(.delete)
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
}
