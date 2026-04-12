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
    
    
    // 로그인 방식
    private var authProvider: AuthProvider = .unknown
    // 탈퇴 검증 정책
    private var verificationPolicy: DeletionVerificationPolicy = .confirmOnly
  
    // 탈퇴 검증 기준
    enum DeletionVerificationPolicy: Equatable {
        case reenterEmail(expectedEmail: String)
        case reauthenticateWithApple(email: String?)
        case confirmOnly
    }

    
    
    
    
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
        case dismiss
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
        let verificationPolicy: DeletionVerificationPolicy
    }
    
    // MARK: - Navigation Route (화면 이동 경로)
    enum Route {
        case dismiss
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
        case .dismiss:
            onNavigation?(.dismiss)
        case .viewDidLoad:
            Task {
                await prepareDeletionContext()
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
extension AccountDeletingViewModel {
    // 탈퇴 화면 진입 시 필요한 전체 상태를 준비하는 메서드
    // - 현재 로그인 방식(provider) 조회
    // - 사용자 프로필(email 등) 조회
    // - 탈퇴 검증 정책(verificationPolicy) 결정
    // - 버튼 활성화 상태 계산
    func prepareDeletionContext() async {
        isLoading = .loading(for: "Loading Page...")
        notifyOutput()
        
        // 이전 화면 상태 초기화 (재진입/재사용 대비)
        resetDeletionState()
        // 현재 로그인 방식 (Apple / Email 등) 조회
        authProvider = authUsecase.currentAuthProvider()
        
        // 로그인된 유저가 없는 경우 (예외 상황)
        guard let currentUserId = authUsecase.currentUserId() else {
            userEmail = nil
            verificationPolicy = .confirmOnly
            updateDeleteButtonEnabled()
            isLoading = .notLoading
            notifyOutput()
            return
        }
        
        // 사용자 프로필 조회 (email, private email 여부 등)
        let result = await profileUsecase.fetchProfile(userId: currentUserId)
        switch result {
        case .success(let profile):
            userEmail = profile.email
            // provider + email 정보를 기반으로 탈퇴 검증 정책 결정
            verificationPolicy = makeVerificationPolicy(
                provider: authProvider,
                email: profile.email,
                isPrivateEmail: profile.isPrivateEmail
            )
        case .failure:
            userEmail = nil
            verificationPolicy = makeVerificationPolicy(
                provider: authProvider,
                email: nil,
                isPrivateEmail: false
            )
        }
        
        updateDeleteButtonEnabled()
        isLoading = .notLoading
        notifyOutput()
    }
    
    // 탈퇴 화면 상태 초기화
    // - 재인증 상태, 동의 여부, 버튼 상태 등을 초기값으로 되돌림
    func resetDeletionState() {
        emailValidateResult = .notEntered
        isAgreed = false
        isDeleteButtonEnabled = false
    }
    
    // 로그인 방식과 이메일 상태를 기반으로 탈퇴 검증 정책 생성
    // - Apple 로그인 또는 private email → 동의만 받고 삭제 시 직접 revoke 시도
    //   필요할 때만 내부적으로 Apple 재인증 fallback 수행
    // - 일반 이메일 로그인 → 이메일 재입력 필요
    // - 그 외 → 단순 확인만으로 탈퇴 가능
    func makeVerificationPolicy(
        provider: AuthProvider,
        email: String?,
        isPrivateEmail: Bool
    ) -> DeletionVerificationPolicy {
        if provider == .apple || isPrivateEmail {
            return .confirmOnly
        }
        
        if let email, !email.isEmpty {
            return .reenterEmail(expectedEmail: email)
        }
        
        return .confirmOnly
    }
    
    
    // 이메일 입력값 검증 처리
    // - 현재 정책이 이메일 재입력일 때만 유효성 검사 수행
    func handleEmailEntered(email: String) {
        switch verificationPolicy {
        case .reenterEmail(let expectedEmail):
            if email.isEmpty {
                emailValidateResult = .notEntered
            } else if email == expectedEmail {
                emailValidateResult = .valid
            } else {
                emailValidateResult = .invalid
            }
        case .reauthenticateWithApple, .confirmOnly:
            emailValidateResult = .notEntered
        }
        
        updateDeleteButtonEnabled()
        notifyOutput()
    }
    
    // 탈퇴 동의 체크 상태 토글
    func handleAgreeButtonTapped() {
        isAgreed.toggle()
        updateDeleteButtonEnabled()
        notifyOutput()
    }
    
    // 현재 상태(동의 여부, 인증 여부 등)를 기반으로 삭제 버튼 활성화 여부 계산
    func updateDeleteButtonEnabled() {
        guard isAgreed else {
            isDeleteButtonEnabled = false
            return
        }
        
        switch verificationPolicy {
        case .reenterEmail:
            isDeleteButtonEnabled = (emailValidateResult == .valid)
        case .reauthenticateWithApple:
            isDeleteButtonEnabled = false
        case .confirmOnly:
            isDeleteButtonEnabled = true
        }
    }
    
    // Apple 재인증 버튼 탭 시 처리
    // - Apple 재인증 후 바로 탈퇴를 진행
    func handleAppleReauthenticationButtonTapped() async {
        guard isAgreed else {
            notifyOutput()
            return
        }
        
        isLoading = .loading(for: "Deleting Account...")
        notifyOutput()
        
        let result = await authUsecase.withdraw()
        handleWithdrawResult(result)
    }

    // 삭제 버튼 탭 시 처리
    // - 버튼 활성화 상태 확인
    // - UseCase를 통해 실제 탈퇴 요청
    // - 결과에 따라 화면 이동 또는 알림 처리
    func handleDeleteButtonTapped() async {
        // 로딩 중 처리
        isLoading = .loading(for: "Deleting Account...")
        notifyOutput()

        guard isDeleteButtonEnabled else {
            isLoading = .notLoading
            notifyOutput()
            return
        }
        
        let result = await authUsecase.withdraw()
        handleWithdrawResult(result)
    }

    func handleWithdrawResult(_ result: DomainResult<Void>) {
        switch result {
        case .success:
            isLoading = .notLoading
            notifyOutput()
            NotificationCenter.default.post(name: .deleteAccount, object: nil)

        case .failure(let error):
            isLoading = .notLoading
            notifyOutput()

            // Apple 재인증 창을 닫은 경우에는 실패 얼럿을 띄우지 않는다.
            if case .cancelled = error {
                return
            }

            onNavigation?(.showAlertToNoticeDeleteAccountFailure)
        }
    }
    
    // 현재 ViewModel 상태를 Output으로 만들어 VC에 전달 (UI 업데이트 트리거)
    func notifyOutput() {
        let output = Output(
            emailVaildateResult: emailValidateResult,
            isAgreed: isAgreed,
            isDeleteButtonEnabled: isDeleteButtonEnabled,
            isLoading: isLoading,
            verificationPolicy: verificationPolicy
        )
        
        // Main Thread에서 UI 업데이트
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
