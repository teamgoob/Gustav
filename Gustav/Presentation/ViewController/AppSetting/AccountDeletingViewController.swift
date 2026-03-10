//
//  AccountDeletingViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/11.
//

import UIKit

// MARK: - AccountDeletingViewController
final class AccountDeletingViewController: UIViewController {
    // MARK: - Properties
    // 뷰 & 뷰 모델
    private let customView = AccountDeletingView()
    private let viewModel: AccountDeletingViewModel
    
    // MARK: - Initializer
    init(viewModel: AccountDeletingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        setupTextField()
        setupButtons()
        setupGesture()
        bindViewModel()
        
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension AccountDeletingViewController {
    // Navigation Item 설정
    func setupNavigationItem() {
        // 네비게이션 타이틀 설정
        navigationItem.title = "Delete Account"
    }
    
    // TextField 설정
    func setupTextField() {
        // 이메일 입력 시 호출될 타겟 메서드 등록
        customView.emailTextField.addTarget(
            self,
            action: #selector(didChangeEmailTextField),
            for: .editingChanged
        )
        // 델리게이트 설정
        customView.emailTextField.delegate = self
    }
    
    // 버튼 타겟 메서드 설정
    func setupButtons() {
        customView.agreeButton.addTarget(
            self,
            action: #selector(didTapAgreeButton),
            for: .touchUpInside
        )
        customView.deleteButton.addTarget(
            self,
            action: #selector(didTapDeleteButton),
            for: .touchUpInside
        )
    }
    
    // 빈 화면 탭 제스처 설정
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // ViewModel Output 바인딩
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
    }
}

// MARK: - Event Handling & Output Apply Method
private extension AccountDeletingViewController {
    // 이메일 텍스트필드 입력 시 호출
    @objc func didChangeEmailTextField() {
        if let text = customView.emailTextField.text {
            viewModel.action(.emailEntered(email: text))
        } else {
            viewModel.action(.emailEntered(email: ""))
        }
    }
    
    // 동의 버튼 선택 시 호출
    @objc func didTapAgreeButton() {
        viewModel.action(.agreeButtonTapped)
    }
    
    // 삭제 버튼 선택 시 호출
    @objc func didTapDeleteButton() {
        viewModel.action(.deleteButtonTapped)
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Output을 UI에 반영
    func apply(_ output: AccountDeletingViewModel.Output) {
        // 로딩 상태 반영
        switch output.isLoading {
        case .loading(for: let text):
            // 전달 받은 로딩 메세지를 반영하여 로딩 뷰 표시
            customView.loadingView.startLoading(with: text)
        case .notLoading:
            customView.loadingView.stopLoading()
        }
        
        // UI 업데이트
        // 이메일 검사 텍스트 업데이트
        switch output.emailVaildateResult {
        case .valid:
            customView.changeValidationLabel(state: .valid)
        case .invalid:
            customView.changeValidationLabel(state: .invalid)
        case .notEntered:
            customView.changeValidationLabel(state: .notEntered)
        }
        // 동의 버튼 상태 업데이트
        customView.setAgreeButtonSelection(to: output.isAgreed)
        // 삭제 버튼 상태 업데이트
        customView.setDeleteButtonAvailability(to: output.isDeleteButtonEnabled)
    }
}

// MARK: - UITextFieldDelegate
extension AccountDeletingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
