//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//
import Foundation

final class CategoryListViewModel {
    // VC가 구독(바인딩)할 콜백
    var onStateChange: ((State) -> Void)?
    
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
    
    // 워크스페이스 아이디
    private var selectedWorkspaceId: UUID
    
    // MARK: - Usecase
    private let categoryUsecase: CategoryUsecaseProtocol
    
    // Task Remote
    private var categoryTask: Task<Void, Never>?

    // 기본 데이터
    private(set) var category: [Category] = [] {
        didSet {
            self.emit(.subTitle(categoryCounting()))
        }
    }
    private var childCategoriesTitle: [UUID: String] = [:]
    
    // 워크스페이스 순서 업데이트시 사용하는 프로퍼티
    private(set) var editingOrderCategory: [Category] = []
    
    // MARK: - init
    init(categoryUsecase: CategoryUsecaseProtocol, selectedWorkspaceId: UUID) {
        self.categoryUsecase = categoryUsecase
        self.selectedWorkspaceId = selectedWorkspaceId
    }
    
    // MARK: - State(Output)
    enum State {
        case loading(Bool)      // 로딩 유무
        case success            // 단순 성공
        case subTitle(String)   // 서브타이틀
    }
    
    // MARK: - Input
    enum Input {
        case dismiss
        case viewDidLoad                                        // viewDidLoad
        case reFetchData                                        // 카테고리 데이터 다시 불러오기
        case didTapAddButton                                    // Add
        case didTapreorderCategoryButton                        // reorder 확정 버튼
        case didReOrderCategories(at: Int, to: Int)             // 순서 변경 중
        case didSelectTapCategory(index: Int)                   // select
        case deleteCategory(at: Int)
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case dismiss                           
        case pushToCategoryDetail(Category)   // 워크스페이스 디테일한 화면 이동
        case presentCreateCategory(Category)  // 추후 생성 알럿을 코디네이터 역할로 변경시 사용
        case showErrorAlert(String)             // 에러 알럿창
    }
    
    
    // Action
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            self.onNavigation?(.dismiss)
        case .viewDidLoad:      // ViewDidLoad
            fetchCategories()
        case .reFetchData:
            reFetchCategories()
        case .didTapAddButton:
            createCategory(name: "New Category")
            
        case .didTapreorderCategoryButton:
            reorderCetegories()
            
        case .didReOrderCategories(at: let from, to: let to):
            updateOrder(moveRowAt: from, to: to)
            
        case .didSelectTapCategory(let index):
            let category = category[index]
            onNavigation?(.pushToCategoryDetail(category))
            
        case .deleteCategory(at: let index):
            self.deleteCategory(at: index)
        }
    }
    
    // Fetch
    private func fetchCategories() {
        emit(.subTitle(categoryCounting()))
        categoryTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        categoryTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조

            self.emit(.loading(true))       // 로딩 시작
            defer { self.emit(.loading(false) ) }    // 끝나면 로딩 끝
            
            #if DEBUG
            try? await Task.sleep(for: .seconds(1))
            #endif
            
            let result = await self.categoryUsecase.fetchCategories(workspaceId: selectedWorkspaceId)

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let category):
                self.category = category
                makeChildCategoriesTitle(categories: category)
                self.emit(.success)

            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    private func reFetchCategories() {
        categoryTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        categoryTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조
            
            let result = await self.categoryUsecase.fetchCategories(workspaceId: selectedWorkspaceId)

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let category):
                self.category = category
                makeChildCategoriesTitle(categories: category)
                self.emit(.success)

            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // Create
    private func createCategory(name: String) {
        categoryTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬
        categoryTask = Task { [weak self] in
            guard let self else { return }
            
            let newCategory = Category(
                id: UUID(),
                workspaceId: self.selectedWorkspaceId,
                parentId: nil,
                indexKey: self.category.count,
                name: name,
                color: TagColor.darkGray)
            let result = await self.categoryUsecase.createCategory(category: newCategory)
            switch result {
            case .success(let category):
                self.category.append(category)
                self.emit(.success)
                self.onNavigation?(.presentCreateCategory(category))
            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    // 워크스페이스 순서 변경 내용 임시 저장
    func updateOrder(moveRowAt : Int, to : Int) {
        if editingOrderCategory.isEmpty {
            self.editingOrderCategory = category
        }
        let movedItem = editingOrderCategory.remove(at: moveRowAt)
        editingOrderCategory.insert(movedItem, at: to)
    }
    
    // Reorder
    private func reorderCetegories() {
        guard !editingOrderCategory.isEmpty else { return }
        
        categoryTask?.cancel()
        categoryTask = Task { [weak self] in
            guard let self else { return }
            
            self.emit(.loading(true))
            var draftCategories: [Category] = []
            var uuidArray: [UUID] = []
            var index: Int = 0
            
            for category in self.editingOrderCategory {
                draftCategories.append(Category(
                    id: category.id,
                    workspaceId: category.workspaceId,
                    parentId: category.parentId,
                    indexKey: category.indexKey,
                    name: category.name,
                    color: category.color))
                uuidArray.append(category.id)
                index += 1
            }
            
            let result = await self.categoryUsecase.reorderCategories(workspaceId: selectedWorkspaceId, order: uuidArray)
            
            #if DEBUG
            try? await Task.sleep(for: .seconds(1))
            #endif
            self.emit(.loading(false) )
            switch result {
            case .success:
                self.category = draftCategories
                self.editingOrderCategory.removeAll()
                emit(.success)
            case .failure(let error):
                self.editingOrderCategory.removeAll()
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    private func deleteCategory(at index: Int) {
        let targetCategory = category[index]
        
        categoryTask?.cancel()
        categoryTask = Task { [weak self] in
            guard let self else { return }
            
            let result = await self.categoryUsecase.deleteCategory(id: targetCategory.id, workspaceId: selectedWorkspaceId)
            
            switch result {
            case .success:
                self.category.remove(at: index)
                self.makeChildCategoriesTitle(categories: self.category)
                self.emit(.success)
            case .failure(let error):
                self.onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    // cell에 사용할 하위 카테고리 리스트 문자열
    private func makeChildCategoriesTitle(categories: [Category]) {
        
        for parentCategory in categories {
            var titleArray: [String] = []
            for childCategory in categories where childCategory.parentId == parentCategory.id {
                titleArray.append(childCategory.name)
            }
            childCategoriesTitle[parentCategory.id] = titleArray.joined(separator: "/")
        }
    }
    
    private func categoryCounting() -> String {
        return "\(category.count) Categories"
    }
    
    func numberOfRows() -> Int {
        category.count
    }
    func cellForRowAt(index: Int) -> Category {
        category[index]
    }
    
    func getChildCategoriesTitle(categoryId: UUID) -> String? {
        childCategoriesTitle[categoryId] ?? nil
    }
    
    private func cancel() {
        categoryTask?.cancel()     // Task 객체에게 취소 플래그 전달
        categoryTask = nil         // Task 객체는 누가 참조하지 않아도 존재 가능하며, 뷰모델에서는 참조 해제
    }

    // 갱신은 메인스레드에서
    @MainActor
    private func emit(_ state: State) {
        onStateChange?(state)
    }

    // MARK: - Deinit
    deinit {
        print("CategoryListViewModel deinit")
        cancel()
        category.removeAll()
    }
}
