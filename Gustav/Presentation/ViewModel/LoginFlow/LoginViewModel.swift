//
//  LoginViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import Foundation
import Combine

//  입력 상태 관리 + 로그인 실행 + 화면 이동 요청 + UI 상태 계산
final class LoginViewModel {
    /*
     하는 일
     
     •    이메일 입력 상태 관리
     •    비밀번호 입력 상태 관리
     •    로그인 실행
     •    회원가입 화면 이동 요청
     •    로그인 버튼 활성화 여부 계산
     •    에러 메시지 생성
     
     */
    // MARK: - Input
    // View → ViewModel 이벤트 전달 구조
    
    enum Input {
        case updateEmail(String)
        case updatePassword(String)
        case tapCreateAccount
        case tapForgotPassword
        case tapAppleLogin
    }
    
    // MARK: - Loading State
    // 로딩 상태의 종류를 구별하기 위한 열거형
    enum LoadingState {
        case loading(for: String)
        case notLoading
    }
    
    // MARK: - Route
    // ViewModel → ViewController one-shot 라우팅 전달 구조
    enum Route {
        case showEmailSignUp
        case showForgotPassword
    }
    
    // MARK: - Output
    // ViewModel → ViewController 상태 전달 구조
    
    struct Output {
        let emailErrorMessage: String?
        let passwordErrorMessage: String?
        let generalErrorMessage: String?
        let isLoginButtonEnabled: Bool
        let isLoading: LoadingState
    }
    
    var onDisplay: ((Output) -> Void)?
    var onNavigation: ((Route) -> Void)?

    private let authUseCase: AuthUseCaseProtocol
    private let validator: AuthValidatorProtocol

    // 현재 입력된 이메일
    private var email: String = ""
    // 현재 입력된 비밀번호
    private var password: String = ""

    // 로그인 실패 메시지
    private var generalErrorMessage: String?
    
    // 로그인 진행 상태
    private var isLoading: LoadingState = .notLoading
    // MARK: - init
    init(
        authUseCase: AuthUseCaseProtocol,
        validator: AuthValidatorProtocol = DefaultAuthValidator()
    ) {
        self.authUseCase = authUseCase
        self.validator = validator
    }

    // MARK: - 함수
    // ViewController에서 UI 이벤트를 전달하는 함수
    func action(input: Input) {
        switch input {
            //이메일 상태 업데이트
        case .updateEmail(let email):
            self.email = email
            generalErrorMessage = nil // 이전 로그인 실패 메시지 제거
            notifyOutput()

            //비밀번호 상태 업데이트
        case .updatePassword(let password):
            self.password = password
            generalErrorMessage = nil
            notifyOutput()

            // 회원가입 버튼
        case .tapCreateAccount:
            onNavigation?(.showEmailSignUp)

            // 비밀번호 찾기 화면 이동
        case .tapForgotPassword:
            onNavigation?(.showForgotPassword)

            // Apple 로그인은 ViewController에서 async 처리
        case .tapAppleLogin:
            break
        }
    }

    // 로그인 실행 함수
    func submitLogin() async {
        print("submitLogin called")
        // 입력 검증
        let emailError = validator.validateEmail(email)
        let passwordError = validator.validateSignInPassword(password)

        // 검증 실패
        guard emailError == nil, passwordError == nil else {
            generalErrorMessage = nil
            notifyOutput()
            return
        }

        // 로딩 시작
        isLoading = .loading(for: "Signing In...")
        generalErrorMessage = nil
        notifyOutput()

        let result = await authUseCase.signInWithEmail(
            email: email,
            password: password
        )

        isLoading = .notLoading
        
        // 결과 처리
        switch result {
        case .success(let outcome):
            generalErrorMessage = nil

            switch outcome {
            case .authenticated(_, _):
                NotificationCenter.default.post(name: .login, object: nil)

            case .emailVerificationRequired:
                generalErrorMessage = "이메일 인증 후 로그인해주세요."
            }

        case .failure(let error):
            print("login failed:", error)
            generalErrorMessage = mapDomainErrorToMessage(error)
        }
        notifyOutput()
    }
    
    // 애플 로그인 핸들링
    func handleAppleLogin() async {
        isLoading = .loading(for: "Signing In with Apple...")
        generalErrorMessage = nil
        notifyOutput()

        let result = await authUseCase.authenticateWithApple()

        isLoading = .notLoading
        
        switch result {
        case .success(let outcome):
            generalErrorMessage = nil

            switch outcome {
            case .authenticated(_, _):
                NotificationCenter.default.post(name: .login, object: nil)

            case .emailVerificationRequired:
                generalErrorMessage = "이메일 인증 후 로그인해주세요."
            }

        case .failure(let error):
            generalErrorMessage = mapDomainErrorToMessage(error)
        }
        notifyOutput()
    }

    // ViewController가 현재 UI 상태를 가져오는 함수
    func getCurrentOutput() -> Output {
        let emailError = shouldShowEmailError ? validator.validateEmail(email) : nil
        let passwordError = shouldShowPasswordError ? validator.validateSignInPassword(password) : nil

        return Output(
            emailErrorMessage: mapEmailErrorToMessage(emailError),
            passwordErrorMessage: mapPasswordErrorToMessage(passwordError),
            generalErrorMessage: generalErrorMessage,
            isLoginButtonEnabled: canSubmitLogin(),
            isLoading: isLoading
        )
    }
}

private extension LoginViewModel {
    
    // 입력이 있을 때만 에러 표시
    var shouldShowEmailError: Bool {
        !email.isEmpty
    }

    var shouldShowPasswordError: Bool {
        !password.isEmpty
    }

    // 로그인 버튼 활성화 조건
    func canSubmitLogin() -> Bool {
        guard case .notLoading = isLoading else { return false }
        
        let emailError = validator.validateEmail(email)
        let passwordError = validator.validateSignInPassword(password)

        return emailError == nil && passwordError == nil
    }
    
    func mapEmailErrorToMessage(_ error: AuthInputError?) -> String? {
        guard let error else { return nil }

        switch error {
        case .invalidEmailFormat:
            return "Invalid email format."
        case .emptyEmail:
            return nil
        default:
            return nil
        }
    }

    func mapPasswordErrorToMessage(_ error: AuthInputError?) -> String? {
        guard let error else { return nil }

        switch error {
        case .emptyPassword:
            return nil
        default:
            return nil
        }
    }
    
    func mapDomainErrorToMessage(_ error: DomainError) -> String {
        switch error {
        case .cancelled:
            return "Sign-in was cancelled."

        case .temporarilyUnavailable:
            return "The service is temporarily unavailable. Please try again later."

        case .authenticationRequired:
            return "Authentication is required. Please sign in again."
            
        case .entityNotFound:
            return "No account was found with the provided credentials."
            
        case .unknown:
            return "An unexpected error occurred. Please try again."

        default:
            return "Unable to sign in. Please check your credentials and try again."
        }
    }
    
    func notifyOutput() {
        let output = getCurrentOutput()
        
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
