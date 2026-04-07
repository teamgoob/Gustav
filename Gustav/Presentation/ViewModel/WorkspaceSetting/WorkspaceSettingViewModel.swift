//
//  WorkspaceSettingViewModel.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/20.
//

import Foundation

// MARK: - WorkspaceSettingViewModel
final class WorkspaceSettingViewModel {
    private let workspaceUsecase: WorkspaceUsecaseProtocol
    // 설정 중인 워크스페이스 정보
    private let workspace: Workspace
    
    init(workspace: Workspace, workspaceUsecase: WorkspaceUsecaseProtocol) {
        self.workspace = workspace
        self.workspaceUsecase = workspaceUsecase
        
        // 설정 목록 초기화
        configureSections()
    }
    
    // MARK: - 화면 상태 값 (변화 X)
    // 설정 목록 배열
    private var settingListSections: [SettingListSection] = []
    
    // 설정 목록 섹션 구성을 저장하기 위한 구조체
    struct SettingListSection {
        let items: [SettingListItem]
    }
    
    // 각 설정을 구분하기 위한 열거형
    enum SettingListItem {
        case categorySettings
        case setCategoriesInBulk
        case locationSettings
        case setLocationsInBulk
        case itemStateSettings
        case setItemStatesInBulk
        case viewPresetSettings
        case deleteWorkspace
    }
    
    // MARK: - 화면 상태 값 (변화 O)
    // 로딩 상태
    private var isLoading: LoadingState = .notLoading
    
    // 로딩 상태의 종류를 구별하기 위한 열거형
    enum LoadingState {
        case loading(for: String)
        case notLoading
    }
    
    // MARK: - Input
    enum Input {
        case dismiss
        case viewDidLoad
        case didSelectSettingListItem(SettingListItem)
        case confirmDeleteWorkspace
    }
    
    // MARK: - Output
    struct Output {
        let workspaceName: String
        let isLoading: LoadingState
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case dismiss
        case pushTo(next: SettingListItem)
        case showAlertForDeletingWorkspaceConfirmation
        case finishedToDeleteWorkspace(success: Bool)
    }
    
    // MARK: - Closures
    // Output 변경 시 VC에 전달하여 화면 업데이트
    var onDisplay: ((Output) -> Void)?
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
}

// MARK: - 외부 호출 메서드
extension WorkspaceSettingViewModel {
    // Input 처리 메서드
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            onNavigation?(.dismiss)
        case .viewDidLoad:
            showWorkspaceName()
        case .didSelectSettingListItem(let item):
            handleSettingListSelection(item: item)
        case .confirmDeleteWorkspace:
            Task {
                await handleDeleteWorkspace()
            }
        }
    }
    
    // TableView DataSource 메서드
    // 섹션 개수
    var numberOfSections: Int {
        settingListSections.count
    }
    
    // 특정 섹션의 아이템 수
    func numberOfRows(in section: Int) -> Int {
        settingListSections[section].items.count
    }
    
    // 특정 아이템 정보
    func rowItem(section: Int, row: Int) -> SettingListItem {
        settingListSections[section].items[row]
    }
}

// MARK: - Private Logic
// 설정 목록 초기화, 이벤트 처리 및 화면 업데이트 메서드 구현
private extension WorkspaceSettingViewModel {
    // 설정 목록 초기화
    func configureSections() {
        let workspaceContextSetting = SettingListSection(items: [
            .categorySettings,
            .locationSettings,
            .itemStateSettings
        ])
        
        let viewPresetSetting = SettingListSection(items: [
            .viewPresetSettings
        ])
        
        let workspaceSetting = SettingListSection(items: [
            .deleteWorkspace
        ])
        
        self.settingListSections = [workspaceContextSetting, viewPresetSetting, workspaceSetting]
    }
    
    // 워크스페이스 이름 불러오기
    func showWorkspaceName() {
        notifyOutput()
    }
    
    // 설정 목록 선택 이벤트 처리
    func handleSettingListSelection(item: SettingListItem) {
        switch item {
        case .deleteWorkspace:
            onNavigation?(.showAlertForDeletingWorkspaceConfirmation)
        default:
            onNavigation?(.pushTo(next: item))
        }
    }
    
    // 워크스페이스 삭제 처리
    func handleDeleteWorkspace() async {
        // 로딩 중 처리
        isLoading = .loading(for: "Deleting Workspace...")
        notifyOutput()
        
        let result = await workspaceUsecase.deleteWorkspace(id: self.workspace.id)
        switch result {
        case .success:
            // 로딩 완료 처리
            isLoading = .notLoading
            onNavigation?(.finishedToDeleteWorkspace(success: true))
        case .failure:
            // 로딩 완료 처리
            isLoading = .notLoading
            // 화면 표시
            notifyOutput()
            // Coordinator에 로그아웃 실패 전달
            onNavigation?(.finishedToDeleteWorkspace(success: false))
        }
    }
    
    // 현재 상태를 VC에 전달하는 메서드
    func notifyOutput() {
        let output = Output(
            workspaceName: workspace.name,
            isLoading: isLoading
        )
        
        // Main Thread에서 UI 업데이트
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
