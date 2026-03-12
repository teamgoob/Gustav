//
//  LoginViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//

import Foundation

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
    
    // MARK: - Output
    // ViewModel → ViewController 상태 전달 구조
    
    struct Output {
        let emailErrorMessage: String?
        let passwordErrorMessage: String?
        let generalErrorMessage: String?
        let isLoginButtonEnabled: Bool
        let isLoading: Bool
    }

    private let authUseCase: AuthUseCaseProtocol
    private weak var coordinator: AuthCoordinatorProtocol?
    private let validator: AuthValidatorProtocol

    // 현재 입력된 이메일
    private var email: String = ""
    // 현재 입력된 비밀번호
    private var password: String = ""

    // 로그인 실패 메시지
    private var generalErrorMessage: String?
    // 로그인 진행 상태
    private var isLoading: Bool = false

    // MARK: - init
    init(
        authUseCase: AuthUseCaseProtocol,
        coordinator: AuthCoordinatorProtocol?,
        validator: AuthValidatorProtocol = DefaultAuthValidator()
    ) {
        self.authUseCase = authUseCase
        self.coordinator = coordinator
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

            //비밀번호 상태 업데이트
        case .updatePassword(let password):
            self.password = password
            generalErrorMessage = nil

            // 회원가입 버튼
        case .tapCreateAccount:
            coordinator?.showEmailSignUp()

            // 비밀번호 찾기 (아직 구현 안 됨)
        case .tapForgotPassword:
            break

            // Apple 로그인 (아직 구현 안 됨)
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
            return
        }

        // 로딩 시작
        isLoading = true
        generalErrorMessage = nil

        let result = await authUseCase.signInWithEmail(
            email: email,
            password: password
        )

        isLoading = false

        // 결과 처리
        switch result {
        case .success:
            generalErrorMessage = nil

        case .failure(let error):
            print("login failed:", error)
            generalErrorMessage = mapDomainErrorToMessage(error)
        }
    }
    
    // 애플 로그인 핸들링
    func handleAppleLogin() async {
        isLoading = true
        generalErrorMessage = nil

        let result = await authUseCase.authenticateWithApple()

        isLoading = false

        switch result {
        case .success:
            generalErrorMessage = nil

        case .failure(let error):
            generalErrorMessage = mapDomainErrorToMessage(error)
        }
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
        guard !isLoading else { return false }

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
            return "취소하였습니다."

        case .temporarilyUnavailable:
            return "잠시 후 다시 시도해주세요."

        case .authenticationRequired,
             .entityNotFound,
             .unknown:
            return "아이디 또는 비밀번호가 틀렸습니다."

        default:
            return "아이디 또는 비밀번호가 틀렸습니다."
        }
    }
}
