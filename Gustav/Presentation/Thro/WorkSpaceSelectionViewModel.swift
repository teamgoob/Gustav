//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//
import Foundation

final class WorkSpaceSelectionViewModel {

    // VC가 구독(바인딩)할 콜백
    var onStateChange: ((State) -> Void)?
    
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
    
    // MARK: - Usecase
    private let workspaceUsecase: WorkspaceUsecaseProtocol
//    private let authUsecase: AuthUseCaseProtocol
//    private let profileUsecase: ProfileUseCaseProtocol
    
    
    // Task Remote
    private var workspaceTask: Task<Void, Never>?

    // 기본 데이터
    private(set) var workSpaces: [Workspace] = []
    
    // 워크스페이스 이름 업데이트시 사용하는 프로퍼티
    private(set) var editingWorkSpaces: [Int : String] = [:]
    
    // 워크스페이스 순서 업데이트시 사용하는 프로퍼티
    private(set) var editingOrderWorkspaces: [Workspace] = []
    
    // MARK: - init
    init(workspaceUsecase: WorkspaceUsecaseProtocol) {
        self.workspaceUsecase = workspaceUsecase
    }
    // 프로필 속성 수정 후 생성 및 프로필 반영 메서드 구현 필요
//    init(
//        workspaceUsecase: WorkspaceUsecaseProtocol,
//        authenticationUsecase: AuthUseCaseProtocol,
//        profileUsecase: ProfileUseCaseProtocol
//    ) {
//        self.workspaceUsecase = workspaceUsecase
//        self.authUsecase = authenticationUsecase
//        self.profileUsecase = profileUsecase
//    }
    // MARK: - State(Output)
    enum State {
        case loading(Bool)      // 로딩 유무
        case data([Workspace])  // 데이터
        case profile(urlstring: String, name: String)   // 프로필 데이터
        case success            // 단순 성공
        case error(String)      // 에러메세지
    }
    
    // MARK: - Input
    enum Input {
        case viewDidLoad                                        // viewDidLoad
        case didTapAddWorkspaceButton(name: String)             // Add Workspace
        case didTapreorderWorkspacesButton                      // reorder 확정 버튼
        case didReOrderWorkspaces(at: Int, to: Int)             // 순서 변경 중
        case didTapupdateWorkspacesNameButton                   // Update
        case didSelectTapWorkspace(index: Int)                  // select
        case didTapAppSetting                                   // pushToAppSettingView
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case pushToAppSetting                   // 앱설정 화면 (프로필)
        case pushToWorkspaceDetail(Workspace)   // 워크스페이스 디테일한 화면 이동
        case presentCreateWorkspace             // 추후 생성 알럿을 코디네이터 역할로 변경시 사용
        case showErrorAlert(String)             // 에러 알럿창
    }
    
    
    // Action
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            fetchWorkspaces()
            
        case .didTapAddWorkspaceButton(let name):
            createWorkspace(name: name)
            
        case .didTapreorderWorkspacesButton:
            reorderWorkspaces()
            
        case .didReOrderWorkspaces(at: let from, to: let to):
            updateOrder(moveRowAt: from, to: to)
        case .didTapupdateWorkspacesNameButton:
            updateWorkspace()
            
        case .didSelectTapWorkspace(let index):
            let workspace = workSpaces[index]
            onNavigation?(.pushToWorkspaceDetail(workspace))
            
        case .didTapAppSetting:
            onNavigation?(.pushToAppSetting)
        }
    }
    
    // 프로필 불러오기
    func fetchProfileData() async {
        
    }
    
    // Fetch
    private func fetchWorkspaces() {
        workspaceTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬

        workspaceTask = Task { [weak self] in   // 새로운 Task 생성 및 Task 저장(메모리 주소 저장)
            guard let self else { return }  // 실행시 다시 강한 참조

            self.emit(.loading(true))       // 로딩 시작
            defer { Task { self.emit(.loading(false)) } }   // 끝나면 로딩 끝
            
            sleep(1)
            let result = await self.workspaceUsecase.fetchWorkspaces()      // fetch

            guard !Task.isCancelled else { return }         // 전달 받은 캔슬 플래그가 있으면 중단

            switch result {
            case .success(let workspaces):
                self.workSpaces = workspaces
                self.emit(.data(workspaces))

            case .failure(let error):
                self.emit(.error(String(describing: error)))
            }
        }
    }

    // Create
    private func createWorkspace(name: String) {
        workspaceTask?.cancel()     // 저장된 비동기 작업이 존재하는 경우 캔슬
        workspaceTask = Task { [weak self] in
            guard let self else { return }
            
            self.emit(.loading(true))
            defer { Task { self.emit(.loading(false)) } }
            
            let result = await self.workspaceUsecase.createWorkspace(name: name)
            switch result {
            case .success(let workspace):
                self.workSpaces.append(workspace)
                self.emit(.data(workSpaces))
            case .failure(let error):
                self.emit(.error(String(describing: error)))
            }
        }
    }
    
    // 워크스페이스 이름 변경 내용 임시 저장
    func updateText(index: Int, text: String) {
        self.editingWorkSpaces[index] = text
        print("워크스페이스 이름 변경 내용 임시 저장 - 인덱스 값\(index), 텍스트 값\(text)")
    }
    
    // Update
    private func updateWorkspace() {
        guard editingWorkSpaces.count > 0 else { return }
        workspaceTask?.cancel()
        workspaceTask = Task { [weak self] in
            guard let self else { return }
            
            self.emit(.loading(true))
            defer { Task { self.emit(.loading(false)) } }
            let keyArray = Array(editingWorkSpaces.keys)
            for i in keyArray {
                guard let name = editingWorkSpaces[i] else {
                    self.emit(.error(workSpaces[i].name + "워크스페이스 이름 변경 실패"))
                    continue
                }
                let _ = await self.workspaceUsecase.updateWorkspaceName(id: self.workSpaces[i].id, name: name)
            }
            let result = await self.workspaceUsecase.fetchWorkspaces()
            switch result {
            case .success(let workspaces):
                self.workSpaces = workspaces
                self.emit(.data(workSpaces))
                self.editingWorkSpaces = [:]
            case .failure(let error):
                self.editingWorkSpaces = [:]
                self.emit(.error(String(describing: error)))
            }
        }
        
    }
    
    // 워크스페이스 순서 변경 내용 임시 저장
    func updateOrder(moveRowAt : Int, to : Int) {
        if editingOrderWorkspaces.isEmpty {
            self.editingOrderWorkspaces = workSpaces
        }
        let movedItem = editingOrderWorkspaces.remove(at: moveRowAt)
        editingOrderWorkspaces.insert(movedItem, at: to)
    }
    
    // Reorder
    private func reorderWorkspaces() {
        workspaceTask?.cancel()
        workspaceTask = Task { [weak self] in
            guard let self else { return }
            
            self.emit(.loading(true))
            defer { Task { self.emit(.loading(false)) } }
            var draftworkspaces: [Workspace] = []
            var uuidArray: [UUID] = []
            var index: Int = 0
            
            for workspace in self.editingOrderWorkspaces {
                draftworkspaces.append(Workspace(
                    id: workspace.id,
                    userId: workspace.userId,
                    indexKey: index,
                    name: workspace.name,
                    createdAt: workspace.createdAt,
                    updatedAt: workspace.updatedAt
                ))
                uuidArray.append(workspace.id)
                index += 1
            }
            
            let result = await self.workspaceUsecase.reorderWorkspaces(order: uuidArray)
            switch result {
            case .success:
                self.workSpaces = draftworkspaces
                self.editingOrderWorkspaces.removeAll()
                emit(.success)
            case .failure:
                self.editingOrderWorkspaces.removeAll()
                emit(.error(""))
            }
        }
    }
    
    private func cancel() {
        workspaceTask?.cancel()     // Task 객체에게 취소 플래그 전달
        workspaceTask = nil         // Task 객체는 누가 참조하지 않아도 존재 가능하며, 뷰모델에서는 참조 해제
    }

    // 갱신은 메인스레드에서
    @MainActor
    private func emit(_ state: State) {
        onStateChange?(state)
    }

    deinit {
        workspaceTask?.cancel()
    }
}
