//
//  ProfileEditingViewModel.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/10.
//

import Foundation

// MARK: - ProfileEditingViewModel
final class ProfileEditingViewModel {
    private let authUsecase: AuthUseCaseProtocol
    private let profileUsecase: ProfileUseCaseProtocol
    
    init(authUsecase: AuthUseCaseProtocol, profileUsecase: ProfileUseCaseProtocol) {
        self.authUsecase = authUsecase
        self.profileUsecase = profileUsecase
    }
    
    // MARK: - 기존 상태 값
    // 기존 프로필 이미지 URL
    private var profileImageUrl: String?
    // 기존 사용자 이름
    private var userName: String?
    // 로딩 상태
    private var isLoading: LoadingState = .notLoading
    
    // MARK: - 새로운 상태 값
    // 새로운 프로필 이미지 URL
    private var newProfileImageUrl: String?
    // 새로운 사용자 이름
    private var newUserName: String?
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case changeProfileImage(url: String)
        case changeUserName(name: String)
        case save
    }
    
    // MARK: - Output
    struct Output {
        let profileImageUrl: String?
        let userName: String?
        let isLoading: LoadingState
    }
    
    // MARK: - Route
    enum Route {
        case dismissAfterSave
        case showAlertToNoticeEditingFailure
    }
    
    // MARK: - Loading State
    // 로딩 상태의 종류를 구별하기 위한 열거형
    enum LoadingState {
        case loading(for: String)
        case notLoading
    }
    
    // MARK: - Closures
    // Output 변경 시 VC에 전달하여 화면 업데이트
    var onDisplay: ((Output) -> Void)?
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
}

// MARK: - 외부 호출 메서드
extension ProfileEditingViewModel {
    // Input 처리 메서드
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            Task {
                await fetchProfile()
            }
        case .changeProfileImage(url: let url):
            handleProfileImageChanged(with: url)
        case .changeUserName(name: let name):
            handleUserNameChanged(to: name)
        case .save:
            Task {
                await saveProfile()
            }
        }
    }
    
    // 프로필 저장 버튼 활성화 여부 판단 메서드
    var isSaveButtonEnabled: Bool {
        // 변경할 이름에서 공백 제거
        let trimmedName = newUserName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        // 변경할 이름 유효성 검사
        let isNameValid = !trimmedName.isEmpty
        // 이름 변경 여부 확인
        let isNameChanged = trimmedName != (userName ?? "")
        // 이미지 변경 여부 확인
        let isImageChanged = newProfileImageUrl != profileImageUrl
        // 프로필 변경 여부 확인
        let hasChange = isNameChanged || isImageChanged
        
        // 프로필 변경 여부 + 이름 유효성 확인
        return isNameValid && hasChange
    }
}

// MARK: - Private Logic
// 이벤트 처리 및 화면 업데이트 메서드 구현
private extension ProfileEditingViewModel {
    // 기존 프로필 정보 불러오기
    func fetchProfile() async {
        // 로딩 중 처리
        isLoading = .loading(for: "Loading Profile...")
        notifyOutput()
        
        // 프로필 정보 불러오기
        guard let currentUserId = authUsecase.currentUserId() else { return }
        let result = await profileUsecase.fetchProfile(userId: currentUserId)
        switch result {
            case .success(let profile):
            // MARK: - 프로필 이미지 관련 메서드 작업 후 수정
//            self.profileImageUrl = profile.profileImageUrl
            self.userName = profile.displayName
        case .failure:
            self.profileImageUrl = nil
            self.userName = nil
        }
        
        // 로딩 완료 처리
        isLoading = .notLoading
        notifyOutput()
    }
    
    // 프로필 이미지 변경 이벤트 처리
    func handleProfileImageChanged(with url: String) {
        self.newProfileImageUrl = url
    }
    
    // 사용자 이름 변경 이벤트 처리
    func handleUserNameChanged(to name: String) {
        self.newUserName = name
    }
    
    // 변경된 프로필 저장
    func saveProfile() async {
        // 프로필 변경 성공 여부 저장
        var successFlag: Bool = true
        
        // 로딩 중 처리
        isLoading = .loading(for: "Saving Profile...")
        notifyOutput()
        
        // 프로필 정보 불러오기
        guard let currentUserId = authUsecase.currentUserId() else { return }
//        if newProfileImageUrl != profileImageUrl, let newProfileImageUrl = newProfileImageUrl {
//            let result = await profileUsecase.updateProfileImage(userId: currentUserId, url: newProfileImageUrl)
//            switch result {
//            case .success:
//                break
//            case .failure:
//                successFlag = false
//            }
//        }
        if newUserName != userName, let newUserName = newUserName {
            let result = await profileUsecase.updateUserName(userId: currentUserId, name: newUserName)
            switch result {
            case .success:
                break
            case .failure:
                successFlag = false
            }
        }
        
        isLoading = .notLoading
        if successFlag {
            onNavigation?(.dismissAfterSave)
        } else {
            onNavigation?(.showAlertToNoticeEditingFailure)
        }
    }
    
    // 현재 상태를 VC에 전달하는 메서드
    func notifyOutput() {
        let output = Output(
            profileImageUrl: profileImageUrl,
            userName: userName,
            isLoading: isLoading
        )
        
        // Main Thread에서 UI 업데이트
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
