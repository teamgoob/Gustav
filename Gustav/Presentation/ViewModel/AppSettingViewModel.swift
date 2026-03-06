//
//  AppSettingViewModel.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/4.
//

import Foundation

// MARK: - AppSettingViewModel
final class AppSettingViewModel {
    private let authUsecase: AuthUseCaseProtocol
    private let profileUsecase: ProfileUseCaseProtocol
    
    init(authUsecase: AuthUseCaseProtocol, profileUsecase: ProfileUseCaseProtocol) {
        self.authUsecase = authUsecase
        self.profileUsecase = profileUsecase
        
        // 설정 목록 초기화
        configureSections()
    }
    
    // MARK: - 화면 상태 값
    // 프로필 이미지 URL
    private var profileImageUrl: String?
    // 사용자 이름
    private var userName: String?
    // 사용자 이메일
    private var userEmail: String?
    // 로딩 상태
    private var isLoading: Bool = false
    
    // 설정 목록 배열
    private var settingListSections: [SettingListSection] = []
    
    // 설정 목록 섹션 구성을 저장하기 위한 구조체
    struct SettingListSection {
        let items: [SettingListItem]
    }
    
    // 각 설정을 구분하기 위한 열거형
    enum SettingListItem {
        case editProfile
        case appInfo
        case privacyPolicy
        case signOut
        case deleteAccount
    }
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case profileEdited
        case didSelectSettingListItem(SettingListItem)
        case confirmSignOut
    }
    
    // MARK: - Output
    struct Output {
        let profileImageUrl: String?
        let userName: String?
        let userEmail: String?
        let isLoading: Bool
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case pushTo(next: SettingListItem)
        case showAlertForSignOutConfirmation
        case showAlertToNoticeSignOutFailure
    }
    
    // MARK: - Closures
    // Output 변경 시 VC에 전달하여 화면 업데이트
    var onDisplay: ((Output) -> Void)?
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
}

// MARK: - 외부 호출 메서드
extension AppSettingViewModel {
    // Input 처리 메서드
    func action(_ input: Input) {
        switch input {
        case .profileEdited:
            Task {
                await fetchProfileDataAndUpdateView()
            }
        case .viewDidLoad:
            Task {
                await fetchProfileDataAndUpdateView()
            }
        case .didSelectSettingListItem(let item):
            handleSettingListSelection(item: item)
        case .confirmSignOut:
            Task {
                await handleSignOut()
            }
        }
    }
    
    // Table View DataSource 메서드
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
private extension AppSettingViewModel {
    // 설정 목록 초기화
    func configureSections() {
        let generalSetting = SettingListSection(items: [
            .editProfile,
            .appInfo,
            .privacyPolicy
        ])
        
        let accountSetting = SettingListSection(items: [
            .signOut,
            .deleteAccount
        ])
        
        self.settingListSections = [generalSetting, accountSetting]
    }
    
    // viewDidLoad 이벤트 처리
    func fetchProfileDataAndUpdateView() async {
        // 로딩 중 처리
        isLoading = true
        notifyOutput()
        
        // 프로필 정보 불러오기
        guard let currentUserId = authUsecase.currentUserId() else { return }
        let result = await profileUsecase.fetchProfile(userId: currentUserId)
        switch result {
            case .success(let profile):
            // MARK: - 프로필 이미지 관련 메서드 작업 후 수정
//            self.profileImageUrl = profile.profileImageUrl
            self.userName = profile.displayName
            self.userEmail = profile.email
        case .failure:
            self.profileImageUrl = nil
            self.userName = nil
            self.userEmail = nil
        }
        
        // 로딩 완료 처리
        isLoading = false
        notifyOutput()
    }
    
    // 설정 목록 선택 이벤트 처리
    func handleSettingListSelection(item: SettingListItem) {
        switch item {
        case .signOut:
            print(item)
            onNavigation?(.showAlertForSignOutConfirmation)
        default:
            print(item)
            onNavigation?(.pushTo(next: item))
        }
    }
    
    // 로그아웃 처리
    func handleSignOut() async {
        let result = await authUsecase.signOut()
        switch result {
        case .success:
            break
        case .failure:
            onNavigation?(.showAlertToNoticeSignOutFailure)
        }
    }
    
    // 현재 상태를 VC에 전달하는 메서드
    func notifyOutput() {
        let output = Output(
            profileImageUrl: profileImageUrl,
            userName: userName,
            userEmail: userEmail,
            isLoading: isLoading
        )
        
        // Main Thread에서 UI 업데이트
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
