//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import Foundation

final class ItemStateListViewModel {
    var onStateChange: ((State) -> Void)?
    var onNavigation: ((Route) -> Void)?

    private let selectedWorkspaceId: UUID
    private let itemStateUsecase: ItemStateUsecaseProtocol
    private var itemStateTask: Task<Void, Never>?

    private(set) var itemStates: [ItemState] = [] {
        didSet {
            emit(.subTitle(itemStateCountText()))
        }
    }

    private(set) var editingOrderItemStates: [ItemState] = []

    enum State {
        case loading(Bool)
        case itemStatesChanged
        case subTitle(String)
    }

    enum Input {
        case dismiss
        case viewDidLoad
        case reFetchData
        case didTapAddButton
        case didTapreorderItemStateButton
        case didReOrderItemState(at: Int, to: Int)
        case didSelectTapItemState(index: Int)
        case deleteItemState(index: Int)
    }

    enum Route {
        case dismiss
        case pushToItemStateDetail(ItemState)
        case presentCreateLocation(ItemState)
        case showErrorAlert(String)
    }

    // MARK: - Init
    init(itemStateUsecase: ItemStateUsecaseProtocol, selectedWorkspaceId: UUID) {
        self.itemStateUsecase = itemStateUsecase
        self.selectedWorkspaceId = selectedWorkspaceId
    }

    // MARK: - Deinit
    deinit {
        itemStateTask?.cancel()
        print("ItemStateListViewModel deinit")
    }
    
    // 입력 처리
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            navigate(.dismiss)
        case .viewDidLoad:
            fetchItemStates(isViewDidLoad: true)
        case .reFetchData:
            fetchItemStates(isViewDidLoad: false)
        case .didTapAddButton:
            createItemState(name: "New ItemState")
        case .didTapreorderItemStateButton:
            reorderItemStates()
        case .didReOrderItemState(let from, let to):
            updateOrder(moveRowAt: from, to: to)
        case .didSelectTapItemState(let index):
            guard itemStates.indices.contains(index) else { return }
            navigate(.pushToItemStateDetail(itemStates[index]))
        case .deleteItemState(let index):
            deleteItemState(at: index)
        }
    }

    // 작업 시작
    private func startTask(_ operation: @escaping () async -> Void) {
        itemStateTask?.cancel()
        itemStateTask = Task {
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
    private func itemStateCountText() -> String {
        "\(itemStates.count) ItemState"
    }

    // 목록 조회
    private func fetchItemStates(isViewDidLoad: Bool) {
        startTask { [weak self] in
            guard let self else { return }

            if isViewDidLoad {
                self.emit(.loading(true))
            }
            defer {
                if isViewDidLoad {
                    self.emit(.loading(false))
                }
            }

#if DEBUG
            try? await Task.sleep(for: .seconds(1))
#endif

            let result = await self.itemStateUsecase.fetchItemStates(workspaceId: self.selectedWorkspaceId)
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let itemStates):
                switch isViewDidLoad {
                case true:
                    self.itemStates = await self.setupCategoryOrder(itemStates: itemStates)
                case false:
                    self.itemStates = itemStates
                }
                self.emit(.itemStatesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 항목 생성
    private func createItemState(name: String) {
        startTask { [weak self] in
            guard let self else { return }
            var indexKey: Int = 0
            if let index = self.itemStates.last?.indexKey { indexKey = index + 1 }
            
            let newItemState = ItemState(
                id: UUID(),
                workspaceId: self.selectedWorkspaceId,
                indexKey: indexKey,
                name: name,
                color: .darkGray
            )

            let result = await self.itemStateUsecase.createItemState(itemState: newItemState)
            guard !Task.isCancelled else { return }

            switch result {
            case .success(let itemState):
                self.itemStates.append(itemState)
                self.emit(.itemStatesChanged)
                self.navigate(.pushToItemStateDetail(itemState))
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 순서 초안 저장
    func updateOrder(moveRowAt: Int, to: Int) {
        if editingOrderItemStates.isEmpty {
            editingOrderItemStates = itemStates
        }

        guard editingOrderItemStates.indices.contains(moveRowAt) else { return }

        let movedItem = editingOrderItemStates.remove(at: moveRowAt)
        let destination = min(to, editingOrderItemStates.count)
        editingOrderItemStates.insert(movedItem, at: destination)
    }

    // 순서 반영
    private func reorderItemStates() {
        guard !editingOrderItemStates.isEmpty else { return }

        startTask { [weak self] in
            guard let self else { return }

            self.emit(.loading(true))
            defer { self.emit(.loading(false)) }

            let orderedIDs = self.editingOrderItemStates.map(\.id)
            let draftItemStates = self.editingOrderItemStates.enumerated().map { index, itemState in
                ItemState(
                    id: itemState.id,
                    workspaceId: itemState.workspaceId,
                    indexKey: index,
                    name: itemState.name,
                    color: itemState.color
                )
            }

            let result = await self.itemStateUsecase.reorderItemStates(
                workspaceId: self.selectedWorkspaceId,
                order: orderedIDs
            )

#if DEBUG
            try? await Task.sleep(for: .seconds(1))
#endif

            self.editingOrderItemStates.removeAll()
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                self.itemStates = draftItemStates
                self.emit(.itemStatesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 항목 삭제
    private func deleteItemState(at index: Int) {
        guard itemStates.indices.contains(index) else { return }
        let targetItemState = itemStates[index]

        startTask { [weak self] in
            guard let self else { return }

            let result = await self.itemStateUsecase.deleteItemState(
                id: targetItemState.id,
                workspaceId: self.selectedWorkspaceId
            )
            guard !Task.isCancelled else { return }

            switch result {
            case .success:
                self.itemStates.remove(at: index)
                self.emit(.itemStatesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 인덱스값 재정렬
    private func setupCategoryOrder(itemStates: [ItemState]) async -> [ItemState] {
        guard !itemStates.isEmpty else { return [] }
        var setupOrderItemStates: [ItemState] = []
        var uuid: [UUID] = []
        for (index, itemState) in itemStates.enumerated() {
            let newItemStates = ItemState(
                id: itemState.id,
                workspaceId: itemState.workspaceId,
                indexKey: index,
                name: itemState.name,
                color: itemState.color,
            )

            setupOrderItemStates.append(newItemStates)
            uuid.append(newItemStates.id)
        }
        
        let result = await itemStateUsecase
            .reorderItemStates(
                workspaceId: self.selectedWorkspaceId,
                order: uuid
            )
        switch result {
        case .success:
            return setupOrderItemStates
        case .failure(let error):
            self.navigate(.showErrorAlert(String(describing: error)))
            return []
        }
    }
    
    // 행 개수
    func numberOfRows() -> Int {
        itemStates.count
    }

    // 행 데이터
    func cellForRowAt(index: Int) -> ItemState {
        itemStates[index]
    }
}
