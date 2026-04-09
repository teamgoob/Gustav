//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import Foundation

final class CategoryListViewModel {
    var onStateChange: ((State) -> Void)?
    var onNavigation: ((Route) -> Void)?

    private let selectedWorkspaceId: UUID
    private let categoryUsecase: CategoryUsecaseProtocol
    private var categoryTask: Task<Void, Never>?

    private(set) var categories: [Category] = [] {
        didSet {
            emit(.subTitle(categoryCountText()))
            rebuildChildCategoriesTitle()
        }
    }

    private var childCategoriesTitle: [UUID: String] = [:]
    private(set) var editingOrderCategories: [Category] = []

    enum State {
        case loading(Bool)
        case categoriesChanged
        case childCategoriesLoaded
        case subTitle(String)
    }

    enum Input {
        case dismiss
        case viewDidLoad
        case reFetchData
        case didTapAddButton
        case didTapreorderCategoryButton
        case didReOrderCategories(at: Int, to: Int)
        case didSelectTapCategory(index: Int)
        case deleteCategory(at: Int)
    }

    enum Route {
        case dismiss
        case pushToCategoryDetail(Category)
        case presentCreateCategory(Category)
        case showErrorAlert(String)
    }

    // MARK: - Init
    init(categoryUsecase: CategoryUsecaseProtocol, selectedWorkspaceId: UUID) {
        self.categoryUsecase = categoryUsecase
        self.selectedWorkspaceId = selectedWorkspaceId
    }
    
    // MARK: - Deinit
    deinit {
        categoryTask?.cancel()
        print("CategoryListViewModel deinit")
    }
    // 입력 처리
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            navigate(.dismiss)
        case .viewDidLoad:
            fetchCategories(showLoading: true)
        case .reFetchData:
            fetchCategories(showLoading: false)
        case .didTapAddButton:
            createCategory(name: "New Category")
        case .didTapreorderCategoryButton:
            reorderCategories()
        case .didReOrderCategories(let from, let to):
            updateOrder(moveRowAt: from, to: to)
        case .didSelectTapCategory(let index):
            guard categories.indices.contains(index) else { return }
            navigate(.pushToCategoryDetail(categories[index]))
        case .deleteCategory(let index):
            deleteCategory(at: index)
        }
    }

    // 작업 시작
    private func startTask(_ operation: @escaping () async -> Void) {
        categoryTask?.cancel()
        categoryTask = Task {
            await operation()
        }
    }

    // 상태 전달
    private func emit(_ state: State) {
        Task { @MainActor in
            self.onStateChange?(state)
        }
    }

    // 화면 이동
    private func navigate(_ route: Route) {
        Task { @MainActor in
            self.onNavigation?(route)
        }
    }

    // 개수 텍스트
    private func categoryCountText() -> String {
        "\(categories.count) Categories"
    }

    // 자식 타이틀 구성
    private func rebuildChildCategoriesTitle() {
        childCategoriesTitle.removeAll()
        childCategoriesTitle = Dictionary(
            uniqueKeysWithValues: categories.map { parentCategory in
                let titles = categories
                    .filter { $0.parentId == parentCategory.id }
                    .map(\.name)
                    .joined(separator: "/")
                return (parentCategory.id, titles)
            }
        )
        emit(.childCategoriesLoaded)
    }

    // 목록 조회
    private func fetchCategories(showLoading: Bool) {
        startTask { [weak self] in
            guard let self else { return }

            if showLoading {
                self.emit(.loading(true))
            }
            defer {
                if showLoading {
                    self.emit(.loading(false))
                }
            }

#if DEBUG
            try? await Task.sleep(for: .seconds(1))
#endif

            let result = await self.categoryUsecase.fetchCategories(workspaceId: self.selectedWorkspaceId)
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let categories):
                self.categories = categories
                self.emit(.categoriesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 항목 생성
    private func createCategory(name: String) {
        startTask { [weak self] in
            guard let self else { return }

            let newCategory = Category(
                id: UUID(),
                workspaceId: self.selectedWorkspaceId,
                parentId: nil,
                indexKey: self.categories.count,
                name: name,
                color: .darkGray
            )

            let result = await self.categoryUsecase.createCategory(category: newCategory)
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let category):
                self.categories.append(category)
                self.emit(.categoriesChanged)
                self.navigate(.presentCreateCategory(category))
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 순서 초안 저장
    func updateOrder(moveRowAt: Int, to: Int) {
        if editingOrderCategories.isEmpty {
            editingOrderCategories = categories
        }

        guard editingOrderCategories.indices.contains(moveRowAt) else { return }

        let movedItem = editingOrderCategories.remove(at: moveRowAt)
        let destination = min(to, editingOrderCategories.count)
        editingOrderCategories.insert(movedItem, at: destination)
    }

    // 순서 반영
    private func reorderCategories() {
        guard !editingOrderCategories.isEmpty else { return }

        startTask { [weak self] in
            guard let self else { return }

            self.emit(.loading(true))
            defer { self.emit(.loading(false)) }

            let orderedIDs = self.editingOrderCategories.map(\.id)
            let draftCategories = self.editingOrderCategories.enumerated().map { index, category in
                Category(
                    id: category.id,
                    workspaceId: category.workspaceId,
                    parentId: category.parentId,
                    indexKey: index,
                    name: category.name,
                    color: category.color
                )
            }

            let result = await self.categoryUsecase.reorderCategories(
                workspaceId: self.selectedWorkspaceId,
                order: orderedIDs
            )

#if DEBUG
            try? await Task.sleep(for: .seconds(1))
#endif

            self.editingOrderCategories.removeAll()
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                self.categories = draftCategories
                self.emit(.categoriesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 항목 삭제
    private func deleteCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        let targetCategory = categories[index]

        startTask { [weak self] in
            guard let self else { return }

            let result = await self.categoryUsecase.deleteCategory(
                id: targetCategory.id,
                workspaceId: self.selectedWorkspaceId
            )
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                self.categories.remove(at: index)
                self.emit(.categoriesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 행 개수
    func numberOfRows() -> Int {
        categories.count
    }

    // 행 데이터
    func cellForRowAt(index: Int) -> Category {
        categories[index]
    }

    // 자식 타이틀 조회
    func getChildCategoriesTitle(categoryId: UUID) -> String? {
        guard let title = childCategoriesTitle[categoryId], !title.isEmpty else { return nil }
        return title
    }
}
