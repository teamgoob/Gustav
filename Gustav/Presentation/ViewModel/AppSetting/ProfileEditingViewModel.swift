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
    private let profileImageUsecase: ProfileImageUsecaseProtocol
    
    init(authUsecase: AuthUseCaseProtocol, profileUsecase: ProfileUseCaseProtocol, profileImageUsecase: ProfileImageUsecaseProtocol) {
        self.authUsecase = authUsecase
        self.profileUsecase = profileUsecase
        self.profileImageUsecase = profileImageUsecase
    }
    
    // MARK: - 기존 상태 값
    // 기존 프로필 이미지 URL
    private var profileImageUrl: String?
    // 기존 사용자 이름
    private var userName: String?
    // 로딩 상태
    private var isLoading: LoadingState = .notLoading
    
    // MARK: - 새로운 상태 값
    // 새로운 프로필 이미지 데이터
    private var newProfileImage: ProfileImageState = .unchanged
    // 새로운 사용자 이름
    private var newUserName: String?
    
    // MARK: - Input
    enum Input {
        case dismiss
        case viewDidLoad
        case didTapProfileImage
        case didSelectImageChange
        case didSelectImageDelete
        case changeProfileImage(data: Data)
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
        case dismiss
        case dismissAfterSave
        case showActionSheetForImage
        case showPhotoLibraryPicker
        case showAlertToNoticeEditingFailure
    }
    
    // MARK: - Loading State
    // 로딩 상태의 종류를 구별하기 위한 열거형
    enum LoadingState {
        case loading(for: String)
        case notLoading
    }
    
    // MARK: - Profile Image State
    // 프로필 이미지 변경 여부를 표현하기 위한 열거형
    enum ProfileImageState {
        case unchanged
        case changed(Data)
        case removed
    }
    
    // MARK: - Closures
    // Output 변경 시 VC에 전달하여 화면 업데이트
    var onDisplay: ((Output) -> Void)?
    // 저장 버튼 활성화 여부 변경 시 VC에 전달하여 화면 업데이트
    var onSaveButtonChanged: (() -> Void)?
    // 새로운 프로필 이미지 선택 시 VC에 전달하여 화면 업데이트
    var onProfileImageChanged: ((Data) -> Void)?
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
}

// MARK: - 외부 호출 메서드
extension ProfileEditingViewModel {
    // Input 처리 메서드
    func action(_ input: Input) {
        switch input {
        case .dismiss:
            onNavigation?(.dismiss)
        case .viewDidLoad:
            Task {
                await fetchProfile()
            }
        case .didTapProfileImage:
            onNavigation?(.showActionSheetForImage)
        case .didSelectImageChange:
            onNavigation?(.showPhotoLibraryPicker)
        case .didSelectImageDelete:
            handleProfileImageDeleted()
        case .changeProfileImage(data: let data):
            handleProfileImageChanged(with: data)
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
        // 이름 변경 여부
        var isNameChanged = false
        // 이미지 변경 여부
        var isImageChanged = false
        // 이름 유효성
        var isNameValid = false
        
        // 이름이 입력된 경우
        if let newUserName = newUserName {
            // 변경할 이름에서 공백 제거
            let trimmedName = newUserName.trimmingCharacters(in: .whitespacesAndNewlines)
            // 변경할 이름 유효성 검사
            isNameValid = !trimmedName.isEmpty
            // 이름 변경 여부 확인
            isNameChanged = trimmedName != (userName ?? "")
        } else {
            isNameValid = true
            isNameChanged = false
        }
        
        // 이미지 변경 여부 확인
        switch newProfileImage {
        case .changed:
            isImageChanged = true
        case .unchanged:
            isImageChanged = false
        case .removed:
            isImageChanged = true
        }
        
        // 프로필 변경 여부 확인
        let hasChange = isNameChanged || isImageChanged
        
        // 프로필 변경 여부 + 이름 유효성 확인
        return isNameValid && hasChange
    }
    
    // 프로필 삭제 버튼 표시 여부 판단 메서드
    var isDeleteButtonVisible: Bool {
        if let _ = profileImageUrl {
            switch newProfileImage {
            case .changed:
                return true
            case .unchanged:
                return true
            case .removed:
                return false
            }
        } else {
            switch newProfileImage {
            case .changed:
                return true
            case .unchanged:
                return false
            case .removed:
                return false
            }
        }
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
            self.profileImageUrl = profile.profileImageUrl
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
    func handleProfileImageChanged(with data: Data) {
        self.newProfileImage = .changed(data)
        onSaveButtonChanged?()
        onProfileImageChanged?(data)
    }
    
    // 프로필 이미지 삭제 이벤트 처리
    func handleProfileImageDeleted() {
        self.newProfileImage = .removed
        onSaveButtonChanged?()
    }
    
    // 사용자 이름 변경 이벤트 처리
    func handleUserNameChanged(to name: String) {
        self.newUserName = name
        onSaveButtonChanged?()
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
        // 프로필 이미지 변경 / 삭제 여부에 따라 메서드 호출
        switch newProfileImage {
        case .changed(let data):
            // 변경된 경우 이미지 업로드
            let uploadResult = await profileImageUsecase.uploadProfileImage(userId: currentUserId, data: data)
            switch uploadResult {
            case .success(let info):
                // 성공 시 프로필 URL 정보 업데이트
                let updateResult = await profileImageUsecase.updateProfileImageUrl(userId: currentUserId, url: info.url)
                switch updateResult {
                case .success:
                    break
                case .failure:
                    successFlag = false
                }
            case .failure:
                successFlag = false
            }
        case .removed:
            // 삭제된 경우 이미지 및 URL 삭제
            let deleteResult = await profileImageUsecase.deleteProfileImage(userId: currentUserId)
            switch deleteResult {
            case .success:
                break
            case .failure:
                successFlag = false
            }
        case .unchanged:
            break
        }
        
        // 사용자 이름이 변경된 경우, 변경된 이름으로 프로필 업데이트
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
