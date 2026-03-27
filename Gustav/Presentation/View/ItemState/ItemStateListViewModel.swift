//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//
import Foundation

final class ItemStateListViewModel {
    // VC가 구독(바인딩)할 콜백
    var onStateChange: ((State) -> Void)?
    
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
    
    // 워크스페이스 아이디
    private var selectedWorkspaceId: UUID
    
    // MARK: - Usecase
    private let itemStateUsecase: ItemStateUsecaseProtocol
    
    // Task Remote
    private var itemStateTask: Task<Void, Never>?

    // 기본 데이터
    private(set) var itemState: [ItemState] = [] {
        didSet {
            self.emit(.subTitle(itemStateCounting()))
        }
    }
    
    // 장소 순서 업데이트시 사용하는 프로퍼티
    private(set) var editingOrderItemState: [ItemState] = []
    
    // MARK: - init
    init(itemStateUsecase: ItemStateUsecaseProtocol, selectedWorkspaceId: UUID) {
        self.itemStateUsecase = itemStateUsecase
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
        case viewDidLoad                                        // viewDidLoad
        case reFetchData                                        // 카테고리 데이터 다시 불러오기
        case didTapAddButton                                    // Add
        case didTapreorderItemStateButton                        // reorder 확정 버튼
        case didReOrderItemState(at: Int, to: Int)             // 순서 변경 중
        case didSelectTapItemState(index: Int)                   // select
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case pushToItemStateDetail(ItemState)   // 워크스페이스 디테일한 화면 이동
        case presentCreateLocation             // 추후 생성 알럿을 코디네이터 역할로 변경시 사용
        case showErrorAlert(String)             // 에러 알럿창
    }
    
    
    // Action
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:      // ViewDidLoad
            fetchItemStates()
        case .reFetchData:
            reFetchItemState()
        case .didTapAddButton:
            createItemState(name: "New ItemState")
            
        case .didTapreorderItemStateButton:
            reorderLocation()
            
        case .didReOrderItemState(at: let from, to: let to):
            updateOrder(moveRowAt: from, to: to)
            
        case .didSelectTapItemState(let index):
            let itemState = itemState[index]
            onNavigation?(.pushToItemStateDetail(itemState))
        }
    }
    
    // Fetch
    private func fetchItemStates() {
        itemStateTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        itemStateTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조

            self.emit(.loading(true))       // 로딩 시작
            defer { self.emit(.loading(false) ) }    // 끝나면 로딩 끝
            
            #if DEBUG
            try? await Task.sleep(for: .seconds(1))
            #endif
            
            let result = await self.itemStateUsecase.fetchItemStates(workspaceId: self.selectedWorkspaceId)

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let itemState):
                self.itemState = itemState
                self.emit(.success)

            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    // reFetch
    private func reFetchItemState() {
        itemStateTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        itemStateTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조
            
            let result = await self.itemStateUsecase.fetchItemStates(workspaceId: self.selectedWorkspaceId)

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let itemState):
                self.itemState = itemState
                self.emit(.success)

            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // Create
    private func createItemState(name: String) {
        itemStateTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬
        itemStateTask = Task { [weak self] in
            guard let self else { return }
            
            let newItemState = ItemState(
                id: UUID(),
                workspaceId: self.selectedWorkspaceId,
                indexKey: itemState.count,
                name: name,
                color: TagColor.darkGray
            )
            let result = await self.itemStateUsecase.createItemState(itemState: newItemState)
            switch result {
            case .success(let itemState):
                self.itemState.append(itemState)
                self.emit(.success)
                
            case .failure(let error):
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    // 워크스페이스 순서 변경 내용 임시 저장
    func updateOrder(moveRowAt : Int, to : Int) {
        if editingOrderItemState.isEmpty {
            self.editingOrderItemState = itemState
        }
        let movedItem = editingOrderItemState.remove(at: moveRowAt)
        editingOrderItemState.insert(movedItem, at: to)
    }
    
    // Reorder
    private func reorderLocation() {
        guard !editingOrderItemState.isEmpty else { return }
        
        itemStateTask?.cancel()
        itemStateTask = Task { [weak self] in
            guard let self else { return }
            
            self.emit(.loading(true))
            var draftItemState: [ItemState] = []
            var uuidArray: [UUID] = []
            var index: Int = 0
            
            for itemState in self.editingOrderItemState {
                draftItemState.append(
                    ItemState(
                        id: itemState.id,
                        workspaceId: itemState.workspaceId,
                        indexKey: index,
                        name: itemState.name,
                        color: itemState.color
                    )
                )
                uuidArray.append(itemState.id)
                index += 1
            }
            
            let result = await self.itemStateUsecase.reorderItemStates(workspaceId: self.selectedWorkspaceId, order: uuidArray)
            
            #if DEBUG
            try? await Task.sleep(for: .seconds(1))
            #endif
            self.emit(.loading(false) )
            switch result {
            case .success:
                self.itemState = draftItemState
                self.editingOrderItemState.removeAll()
                emit(.success)
            case .failure(let error):
                self.editingOrderItemState.removeAll()
                onNavigation?(.showErrorAlert(String(describing: error)))
            }
        }
    }
    
    private func itemStateCounting() -> String {
        return "\(itemState.count) ItemState"
    }
    
    func numberOfRows() -> Int {
        itemState.count
    }
    func cellForRowAt(index: Int) -> ItemState {
        itemState[index]
    }
    
    private func cancel() {
        itemStateTask?.cancel()     // Task 객체에게 취소 플래그 전달
        itemStateTask = nil         // Task 객체는 누가 참조하지 않아도 존재 가능하며, 뷰모델에서는 참조 해제
    }

    // 갱신은 메인스레드에서
    @MainActor
    private func emit(_ state: State) {
        onStateChange?(state)
    }

    deinit {
        cancel()
        itemState.removeAll()
    }
}
