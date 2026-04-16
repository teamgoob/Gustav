//
//  WorkSpaceSelectionViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import Foundation

final class WorkSpaceListViewModel {

    var onStateChange: ((State) -> Void)?
    var onNavigation: ((Route) -> Void)?

    private let workspaceUsecase: WorkspaceUsecaseProtocol
    private let authUsecase: AuthUseCaseProtocol
    private let profileUsecase: ProfileUseCaseProtocol

    private var initialLoadTask: Task<Void, Never>?
    private var workspaceTask: Task<Void, Never>?
    private var profileTask: Task<Void, Never>?

    private(set) var workSpaces: [Workspace] = []
    private(set) var editingWorkSpaces: [Int: String] = [:]
    private(set) var editingOrderWorkspaces: [Workspace] = []

    var isWorkspaceListEmpty: Bool {
        workSpaces.isEmpty
    }

    // 초기화
    init(
        workspaceUsecase: WorkspaceUsecaseProtocol,
        authenticationUsecase: AuthUseCaseProtocol,
        profileUsecase: ProfileUseCaseProtocol
    ) {
        self.workspaceUsecase = workspaceUsecase
        self.authUsecase = authenticationUsecase
        self.profileUsecase = profileUsecase
    }

    enum State {
        case loading(Bool)
        case profile(urlstring: String?, name: String?)
        case workspacesChanged
    }

    enum Input {
        case viewDidLoad
        case reFetchData
        case reFetchProfile
        case didTapAddWorkspaceButton
        case didTapCreateWorkspace(name: String)
        case didTapreorderWorkspacesButton
        case didReOrderWorkspaces(at: Int, to: Int)
        case didTapupdateWorkspacesNameButton
        case didSelectTapWorkspace(index: Int)
        case didTapAppSetting
    }

    enum Route {
        case pushToAppSetting
        case pushToWorkspaceDetail(Workspace)
        case presentCreateWorkspace
        case showErrorAlert(String)
    }

    // 입력 처리
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            loadInitialData()
        case .reFetchData:
            refreshWorkspaces()
        case .reFetchProfile:
            refreshProfile()
        case .didTapAddWorkspaceButton:
            navigate(.presentCreateWorkspace)
        case .didTapCreateWorkspace(let name):
            createWorkspace(name: name)
        case .didTapreorderWorkspacesButton:
            reorderWorkspaces()
        case .didReOrderWorkspaces(let from, let to):
            updateOrder(moveRowAt: from, to: to)
        case .didTapupdateWorkspacesNameButton:
            updateWorkspace()
        case .didSelectTapWorkspace(let index):
            guard workSpaces.indices.contains(index) else { return }
            navigate(.pushToWorkspaceDetail(workSpaces[index]))
        case .didTapAppSetting:
            navigate(.pushToAppSetting)
        }
    }

    // 초기 데이터
    private func loadInitialData() {
        initialLoadTask?.cancel()
        initialLoadTask = Task { [weak self] in
            guard let self else { return }

            self.emit(.loading(true))
            await self.fetchWorkspaces()
            await self.fetchProfileDataAndUpdateView()
            self.emit(.loading(false))
        }
    }

    // 목록 새로고침
    private func refreshWorkspaces() {
        startWorkspaceTask { [weak self] in
            guard let self else { return }
            await self.fetchWorkspaces()
        }
    }

    // 프로필 새로고침
    private func refreshProfile() {
        startProfileTask { [weak self] in
            guard let self else { return }
            await self.fetchProfileDataAndUpdateView()
        }
    }

    // 작업 실행
    private func startWorkspaceTask(_ operation: @escaping () async -> Void) {
        workspaceTask?.cancel()
        workspaceTask = Task {
            await operation()
        }
    }

    // 프로필 실행
    private func startProfileTask(_ operation: @escaping () async -> Void) {
        profileTask?.cancel()
        profileTask = Task {
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

    // 종료 정리
    deinit {
        initialLoadTask?.cancel()
        workspaceTask?.cancel()
        profileTask?.cancel()
    }
}

// MARK: - Data Layer
extension WorkSpaceListViewModel {

    // 목록 조회
    private func fetchWorkspaces() async {

#if DEBUG
        try? await Task.sleep(for: .seconds(2))
#endif

        let result = await workspaceUsecase.fetchWorkspaces()

        guard !Task.isCancelled else { return }

        switch result {
        case .success(let workspaces):
            self.workSpaces = workspaces
            self.emit(.workspacesChanged)
        case .failure(let error):
            navigate(.showErrorAlert(String(describing: error)))
        }
    }

    // 목록 생성
    private func createWorkspace(name: String) {
        startWorkspaceTask { [weak self] in
            guard let self else { return }

            let result = await self.workspaceUsecase.createWorkspace(name: name)

            switch result {
            case .success(let workspace):
                self.workSpaces.append(workspace)
                self.emit(.workspacesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 이름 초안 저장
    func updateText(index: Int, text: String) {
        editingWorkSpaces[index] = text
    }

    // 이름 변경
    private func updateWorkspace() {
        guard !editingWorkSpaces.isEmpty else { return }

        startWorkspaceTask { [weak self] in
            guard let self else { return }

            self.emit(.loading(true))
            defer { self.emit(.loading(false)) }

            let indices = Array(self.editingWorkSpaces.keys).sorted()

            for index in indices {
                guard self.workSpaces.indices.contains(index) else { continue }
                guard let rawName = self.editingWorkSpaces[index] else { continue }

                let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { continue }

                let _ = await self.workspaceUsecase.updateWorkspaceName(
                    id: self.workSpaces[index].id,
                    name: name
                )
            }

            let result = await self.workspaceUsecase.fetchWorkspaces()

#if DEBUG
            try? await Task.sleep(for: .seconds(2))
#endif

            self.editingWorkSpaces = [:]

            switch result {
            case .success(let workspaces):
                self.workSpaces = workspaces
                self.emit(.workspacesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 순서 초안 저장
    func updateOrder(moveRowAt: Int, to: Int) {
        if editingOrderWorkspaces.isEmpty {
            editingOrderWorkspaces = workSpaces
        }

        guard editingOrderWorkspaces.indices.contains(moveRowAt) else { return }

        let movedItem = editingOrderWorkspaces.remove(at: moveRowAt)
        let destination = min(to, editingOrderWorkspaces.count)
        editingOrderWorkspaces.insert(movedItem, at: destination)
    }

    // 순서 변경
    private func reorderWorkspaces() {
        guard !editingOrderWorkspaces.isEmpty else { return }

        startWorkspaceTask { [weak self] in
            guard let self else { return }

            self.emit(.loading(true))
            defer { self.emit(.loading(false)) }

            let orderedIDs = self.editingOrderWorkspaces.map(\.id)
            let draftWorkspaces = self.editingOrderWorkspaces.enumerated().map { index, workspace in
                Workspace(
                    id: workspace.id,
                    userId: workspace.userId,
                    indexKey: index,
                    name: workspace.name,
                    createdAt: workspace.createdAt,
                    updatedAt: workspace.updatedAt
                )
            }

            let result = await self.workspaceUsecase.reorderWorkspaces(order: orderedIDs)

#if DEBUG
            try? await Task.sleep(for: .seconds(2))
#endif

            self.editingOrderWorkspaces.removeAll()

            switch result {
            case .success:
                self.workSpaces = draftWorkspaces
                self.emit(.workspacesChanged)
            case .failure(let error):
                self.navigate(.showErrorAlert(String(describing: error)))
            }
        }
    }

    // 프로필 조회
    private func fetchProfileDataAndUpdateView() async {
        guard let currentUserId = authUsecase.currentUserId() else {
            emit(.profile(urlstring: nil, name: nil))
            return
        }

        let result = await profileUsecase.fetchProfile(userId: currentUserId)

        switch result {
        case .success(let profile):
            emit(.profile(urlstring: profile.profileImageUrl, name: profile.displayName))
        case .failure:
            emit(.profile(urlstring: nil, name: nil))
        }
    }
}
