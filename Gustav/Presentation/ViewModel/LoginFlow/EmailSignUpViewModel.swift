//
//  EmailSignUpViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/11/26.
//
import Foundation

@MainActor
final class EmailSignUpViewModel {
    
    /*
     이 ViewModel의 역할
     
     • 이메일 입력 상태 관리
     • 비밀번호 입력 상태 관리
     • 재입력 비밀번호 상태 관리
     • 약관 동의 상태 관리
     • 회원가입 버튼 활성화 여부 계산
     • authUseCase.signUpWithEmail(...) 호출
     • 성공 / 실패 결과를 화면에 보여줄 상태로 변환
     • 뒤로가기 같은 화면 이동 이벤트 처리
     */
    
    // MARK: - Output Binding
    // ViewController가 바인딩해서 사용하는 출력 전달 클로저
    // state가 바뀌면 현재 Output을 만들어 VC에 전달함
    var onDisplay: ((Output) -> Void)?
    
    // MARK: - Event
    // ViewModel → VC one-shot 이벤트
    var onEvent: ((Event) -> Void)?
    
    // MARK: - Input
    // VC -> VM 으로 전달되는 사용자 액션 종류
    enum Input {
        case updateEmail(String)              // 이메일 입력 변경
        case updatePassword(String)           // 비밀번호 입력 변경
        case updateRepeatPassword(String)     // 비밀번호 재입력 변경
        case updateTermsAgreement(Bool)       // 이용약관 동의 여부 변경
        case updatePrivacyAgreement(Bool)     // 개인정보 동의 여부 변경
        case tapSignUp                        // 회원가입 버튼 탭
        case tapTermsLook                     // 이용약관 보기 탭
        case tapPrivacyLook                   // 개인정보 처리방침 보기 탭
        case tapBack                          // 뒤로가기
    }
    
    // MARK: - Event Type
    enum Event {
        case showError(String)
        case showSuccess(String)
        case showTerms
        case showPrivacy
        case pop
    }

    // MARK: - Output Model
    // VC가 화면을 그릴 때 사용하는 출력값 묶음
    // ViewModel 내부 state를 가공해서 View에 필요한 형태로 전달함
    struct Output {
        let emailErrorMessage: String?            // 이메일 에러 메시지
        let passwordErrorMessage: String?         // 비밀번호 에러 메시지
        let repeatPasswordErrorMessage: String?   // 비밀번호 재입력 에러 메시지
        let isSignUpButtonEnabled: Bool           // 회원가입 버튼 활성화 여부
        let isLoading: Bool                       // 로딩 상태
    }

    // MARK: - Internal State
    // 이 화면의 내부 상태를 한 군데에 모아둔 구조체
    // 흩어진 프로퍼티보다 관리가 쉽고, 테스트와 유지보수에도 유리함
    private struct State {
        var email: String = ""                    // 현재 이메일 입력값
        var password: String = ""                 // 현재 비밀번호 입력값
        var repeatPassword: String = ""           // 현재 비밀번호 재입력값
        var isTermsAgreed: Bool = false           // 이용약관 동의 여부
        var isPrivacyAgreed: Bool = false         // 개인정보 동의 여부
        var isLoading: Bool = false               // 회원가입 요청 진행 중 여부
    }
    
    // MARK: - Dependencies
    // 실제 회원가입 비즈니스 로직 실행 객체
    private let authUseCase: AuthUseCaseProtocol
    
    // 입력값 검증 객체
    // 이메일 형식, 비밀번호 규칙, 비밀번호 재입력 일치 여부 등을 검사
    private let validator: AuthValidatorProtocol

    // 현재 화면 상태 저장소
    private var state = State()

    // MARK: - Initializer
    init(
        authUseCase: AuthUseCaseProtocol,
        validator: AuthValidatorProtocol
    ) {
        self.authUseCase = authUseCase
        self.validator = validator
    }

    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.validator = DefaultAuthValidator()
    }

    // MARK: - State Update
    // 상태를 변경하고, 변경이 끝난 뒤 현재 Output을 한 번만 전달함
    // 여러 상태값을 한 번에 바꾸고 화면 반영도 1번만 발생시키기 위한 헬퍼
    private func updateState(_ updates: () -> Void) {
        updates()
        notifyOutput()
    }

    // MARK: - Input Handling
    // VC에서 전달한 사용자 액션을 처리하는 진입점
    func action(input: Input) async {
        switch input {
        case .updateEmail(let email):
            // 이메일 입력값 변경
            // 입력이 바뀌면 기존 일반 에러/성공 메시지는 지움
            updateState {
                state.email = email
            }
            
        case .updatePassword(let password):
            // 비밀번호 입력값 변경
            updateState {
                state.password = password
            }
            
        case .updateRepeatPassword(let repeatPassword):
            // 비밀번호 재입력값 변경
            updateState {
                state.repeatPassword = repeatPassword
            }
            
        case .updateTermsAgreement(let isChecked):
            // 이용약관 동의 상태 변경
            updateState {
                state.isTermsAgreed = isChecked
            }
            
        case .updatePrivacyAgreement(let isChecked):
            // 개인정보 처리방침 동의 상태 변경
            updateState {
                state.isPrivacyAgreed = isChecked
            }
            
        case .tapSignUp:
            // 회원가입 버튼 눌렀을 때 실제 가입 로직 실행
            await submitSignUp()

        // MARK: - 약관 화면 연결 ⭐️ TODO ⭐️
        // 아직 약관 화면이 없어서 일단 처리 안 함
        // 나중에 coordinator에 showTerms(), showPrivacyPolicy() 추가 예정
        case .tapTermsLook:
            onEvent?(.showTerms)

        case .tapPrivacyLook:
            onEvent?(.showPrivacy)

        case .tapBack:
            onEvent?(.pop)
        }
    }

    // MARK: - Output Mapping
    // 현재 내부 state를 View가 바로 쓸 수 있는 Output 형태로 변환
    func getCurrentOutput() -> Output {
        // 이메일 에러를 지금 보여줘야 하는지 판단 후 검증
        let emailError = shouldShowEmailError ? validator.validateEmail(state.email) : nil
        
        // 비밀번호 에러를 지금 보여줘야 하는지 판단 후 검증
        let passwordError = shouldShowPasswordError ? validator.validatePassword(state.password, minLength: 8) : nil
        
        // 재입력 비밀번호 에러를 지금 보여줘야 하는지 판단 후 검증
        let repeatPasswordError = shouldShowRepeatPasswordError
            ? validator.validateRepeatPassword(password: state.password, repeatPassword: state.repeatPassword)
            : nil

        return Output(
            // 검증 에러를 사용자에게 보여줄 문자열로 변환
            emailErrorMessage: mapInputErrorToMessage(emailError),
            passwordErrorMessage: mapInputErrorToMessage(passwordError),
            repeatPasswordErrorMessage: mapInputErrorToMessage(repeatPasswordError),
            
            // 현재 상태 기준 회원가입 버튼 활성화 가능 여부
            isSignUpButtonEnabled: canSubmitSignUp(),
            
            // 로딩 상태
            isLoading: state.isLoading
        )
    }
}

private extension EmailSignUpViewModel {

// MARK: - Validation Helpers
    
    // 이메일 필드가 비어있지 않을 때만 이메일 에러를 보여줌
    // 처음부터 빨간 에러를 띄우지 않기 위한 용도
    var shouldShowEmailError: Bool {
        !state.email.isEmpty
    }

    // 비밀번호 필드가 비어있지 않을 때만 비밀번호 에러를 보여줌
    var shouldShowPasswordError: Bool {
        !state.password.isEmpty
    }

    // 재입력 비밀번호 필드가 비어있지 않을 때만 에러를 보여줌
    var shouldShowRepeatPasswordError: Bool {
        !state.repeatPassword.isEmpty
    }

    // 회원가입 버튼 활성화 조건 계산
    func canSubmitSignUp() -> Bool {
        // 로딩 중에는 버튼 비활성화
        guard !state.isLoading else { return false }

        // 각 입력값 검증
        let emailError = validator.validateEmail(state.email)
        let passwordError = validator.validatePassword(state.password, minLength: 8)
        let repeatPasswordError = validator.validateRepeatPassword(
            password: state.password,
            repeatPassword: state.repeatPassword
        )

        // 모든 검증 통과 + 약관 동의 완료일 때만 true
        return emailError == nil
            && passwordError == nil
            && repeatPasswordError == nil
            && state.isTermsAgreed
            && state.isPrivacyAgreed
    }

    // MARK: - Sign Up Logic
    // 실제 회원가입 실행
    func submitSignUp() async {
        // 서버 요청 전에 먼저 입력값 검증
        let emailError = validator.validateEmail(state.email)
        let passwordError = validator.validatePassword(state.password, minLength: 8)
        let repeatPasswordError = validator.validateRepeatPassword(
            password: state.password,
            repeatPassword: state.repeatPassword
        )

        // 입력값 중 하나라도 잘못됐으면 서버 요청 안 보냄
        guard emailError == nil,
              passwordError == nil,
              repeatPasswordError == nil
        else {
            // 필드 에러는 getCurrentOutput()에서 계산해서 보여주므로
            // 현재 상태만 다시 전달해서 화면이 즉시 갱신되게 함
            notifyOutput()
            return
        }

        // 약관 동의 안 되어 있으면 서버 요청 안 보냄
        guard state.isTermsAgreed, state.isPrivacyAgreed else {
            onEvent?(.showError(agreementErrorMessageIfNeeded() ?? "약관 동의가 필요합니다."))
            return
        }

        // 요청 시작
        updateState {
            state.isLoading = true
        }
        
        // UseCase를 통해 실제 회원가입 요청
        let result = await authUseCase.signUpWithEmail(
            email: state.email,
            password: state.password
        )
        
        // 결과 처리
        switch result {
        case .success:
            // 회원가입 성공
            // 현재 문구상 이메일 인증 필요 안내를 띄움
            updateState {
                state.isLoading = false
            }
            onEvent?(.showSuccess("Check your email to confirm your account."))

        case .failure(let error):
            // 회원가입 실패
            // DomainError를 사용자 메시지로 변환해서 저장
            updateState {
                state.isLoading = false
            }
            onEvent?(.showError(mapDomainErrorToMessage(error)))
        }
    }

    // MARK: - Error Mapping
    // 약관 미동의 시 보여줄 일반 에러 메시지
    func agreementErrorMessageIfNeeded() -> String? {
        if !state.isTermsAgreed || !state.isPrivacyAgreed {
            return "약관 동의가 필요합니다."
        }
        return nil
    }

    // 입력 검증 에러 -> 사용자 표시용 문자열 변환
    func mapInputErrorToMessage(_ error: AuthInputError?) -> String? {
        guard let error else { return nil }

        switch error {
        case .invalidEmailFormat:
            return "Invalid email format."
            
        // 빈 값은 아직 입력 전일 수 있으니 여기서는 메시지 안 보여줌
        case .emptyEmail:
            return nil
        case .emptyPassword:
            return nil
        case .emptyRepeatPassword:
            return nil
            
        case .passwordTooShort(let minLength):
            return "Password must be \(minLength) or more characters."
            
        case .passwordMissingSpecialCharacter:
            return "Password must include a special character."
            
        case .passwordMismatch:
            return "Passwords do not match."
        }
    }

    // DomainError -> 사용자 표시용 문자열 변환
    func mapDomainErrorToMessage(_ error: DomainError) -> String {
        switch error {
        case .authenticationRequired:
            return "Authentication is required."
            
        case .permissionDenied:
            return "Permission denied."
            
        case .entityNotFound:
            return "Account not found."
            
        case .invalidOperation:
            return "Invalid operation."
            
        case .invalidParameter:
            return "Invalid parameter."
            
        case .invalidInput(let inputError):
            return mapInputErrorToMessage(inputError) ?? "Invalid input."
            
        case .temporarilyUnavailable:
            return "Temporary server error. Please try again."
            
        case .cancelled:
            return "The operation was cancelled."
            
        case .unknown:
            return "An unknown error occurred."
            
        case .emailAlreadyInUse:
            return "This email is already in use."
        }
    }
    
    // MARK: - Notify Output
    // 현재 상태를 Output으로 만들어 VC에 전달
    private func notifyOutput() {
        let output = getCurrentOutput()
        onDisplay?(output)
    }
}
