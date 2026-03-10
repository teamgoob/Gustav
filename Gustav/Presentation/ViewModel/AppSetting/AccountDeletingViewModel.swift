//
//  AccountDeletingViewModel.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/11.
//

import Foundation

// MARK: - AccountDeletingViewModel
final class AccountDeletingViewModel {
    private let authUsecase: AuthUseCaseProtocol
    private let profileUsecase: ProfileUseCaseProtocol
    
    init(authUsecase: AuthUseCaseProtocol, profileUsecase: ProfileUseCaseProtocol) {
        self.authUsecase = authUsecase
        self.profileUsecase = profileUsecase
    }
    
    // MARK: - 화면 상태 값
    // 사용자 이메일
    private var userEmail: String?
    // 이메일 유효성 검사 결과
    private var emailValidateResult: EmailValidateResult = .notEntered
    // 계정 삭제 동의 여부
    private var isAgreed: Bool = false
    // 삭제 버튼 활성화 여부
    private var isDeleteButtonEnabled: Bool = false
    // 로딩 상태
    private var isLoading: LoadingState = .notLoading
    
    // MARK: - Email Validation Result
    // 이메일 유효성 검사 결과
    enum EmailValidateResult {
        case valid
        case invalid
        case notEntered
    }
    
    // MARK: - Loading State
    // 로딩 상태의 종류를 구별하기 위한 열거형
    enum LoadingState {
        case loading(for: String)
        case notLoading
    }
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case emailEntered(email: String)
        case agreeButtonTapped
        case deleteButtonTapped
    }
    
    // MARK: - Output
    struct Output {
        let emailVaildateResult: EmailValidateResult
        let isAgreed: Bool
        let isDeleteButtonEnabled: Bool
        let isLoading: LoadingState
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case dismissAfterDeleteAccount
        case showAlertToNoticeDeleteAccountFailure
    }
    
    // MARK: - Closures
    // Output 변경 시 VC에 전달하여 화면 업데이트
    var onDisplay: ((Output) -> Void)?
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
}

// MARK: - 외부 호출 메서드
extension AccountDeletingViewModel {
    // Input 처리 메서드
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            Task {
                await fetchUserEmail()
            }
        case .emailEntered(email: let email):
            handleEmailEntered(email: email)
        case .agreeButtonTapped:
            handleAgreeButtonTapped()
        case .deleteButtonTapped:
            Task {
                await handleDeleteButtonTapped()
            }
        }
    }
}

// MARK: - Private Logic
// 이벤트 처리 및 화면 업데이트 메서드 구현
private extension AccountDeletingViewModel {
    // 사용자 이메일 불러오기
    func fetchUserEmail() async {
        // 로딩 중 처리
        isLoading = .loading(for: "Loading Page...")
        notifyOutput()
        
        // 사용자 이메일 정보 불러오기
        guard let currentUserId = authUsecase.currentUserId() else { return }
        let result = await profileUsecase.fetchProfile(userId: currentUserId)
        switch result {
        case .success(let profile):
            self.userEmail = profile.email
        case .failure:
            self.userEmail = nil
        }
        
        // 로딩 완료 처리
        isLoading = .notLoading
        notifyOutput()
    }
    
    // 이메일 입력 이벤트 처리 메서드
    func handleEmailEntered(email: String) {
        if email.isEmpty {
            emailValidateResult = .notEntered
            isDeleteButtonEnabled = false
        } else if email == userEmail {
            emailValidateResult = .valid
            if isAgreed {
                isDeleteButtonEnabled = true
            } else {
                isDeleteButtonEnabled = false
            }
        } else {
            emailValidateResult = .invalid
            isDeleteButtonEnabled = false
        }
        notifyOutput()
    }
    
    // 동의 버튼 선택 이벤트 처리 메서드
    func handleAgreeButtonTapped() {
        if isAgreed {
            isAgreed = false
            isDeleteButtonEnabled = false
        } else {
            isAgreed = true
            if emailValidateResult == .valid {
                isDeleteButtonEnabled = true
            } else {
                isDeleteButtonEnabled = false
            }
        }
        notifyOutput()
    }
    
    // 회원 탈퇴 버튼 선택 이벤트 처리 메서드
    func handleDeleteButtonTapped() async {
        // 회원 탈퇴 성공 여부 저장
        var successFlag: Bool = true
        
        // 로딩 중 처리
        isLoading = .loading(for: "Deleting Account...")
        notifyOutput()
        
        // 회원 탈퇴 시도
        let result = await authUsecase.withdraw()
        // 결과 확인
        switch result {
        case .success:
            break
        case .failure:
            successFlag = false
        }
        
        // 로딩 완료 처리
        isLoading = .notLoading
        // 결과에 따라 화면 이동 처리
        if successFlag {
            onNavigation?(.dismissAfterDeleteAccount)
        } else {
            onNavigation?(.showAlertToNoticeDeleteAccountFailure)
        }
    }
    
    // 현재 상태를 VC에 전달하는 메서드
    func notifyOutput() {
        let output = Output(
            emailVaildateResult: emailValidateResult,
            isAgreed: isAgreed,
            isDeleteButtonEnabled: isDeleteButtonEnabled,
            isLoading: isLoading
        )
        
        // Main Thread에서 UI 업데이트
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
