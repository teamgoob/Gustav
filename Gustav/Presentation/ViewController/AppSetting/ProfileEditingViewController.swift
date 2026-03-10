//
//  ProfileEditingViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/10.
//

import UIKit
import Kingfisher

// MARK: - ProfileEditingViewController
final class ProfileEditingViewController: UIViewController {
    // MARK: - Properties
    // 뷰 & 뷰 모델
    private let customView = ProfileEditingView()
    private let viewModel: ProfileEditingViewModel
    // 저장 버튼
    private lazy var saveButton = UIBarButtonItem(
        image: UIImage(systemName: "checkmark"),
        style: .prominent,
        target: self,
        action: #selector(didTapSaveButton)
    )
    
    // MARK: - Initializer
    init(viewModel: ProfileEditingViewModel) {
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
        setupGesture()
        bindViewModel()
        
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension ProfileEditingViewController {
    // Navigation Item 설정
    func setupNavigationItem() {
        // 네비게이션 타이틀 설정
        navigationItem.title = "Edit Profile"
        // 네비게이션 바 우측 저장 버튼 설정
        navigationItem.rightBarButtonItem = saveButton
        // 저장 버튼 비활성화
        saveButton.isEnabled = false
    }
    
    // TextField 설정
    func setupTextField() {
        // 이름 수정 시 호출될 타겟 메서드 등록
        customView.nameTextField.addTarget(
            self,
            action: #selector(didChangeNameTextField),
            for: .editingChanged
        )
        // 델리게이트 설정
        customView.nameTextField.delegate = self
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
private extension ProfileEditingViewController {
    // 저장 버튼 상태 업데이트
    func updateSaveButtonState() {
        saveButton.isEnabled = viewModel.isSaveButtonEnabled
    }
    
    // 저장 버튼 선택 시 호출
    @objc func didTapSaveButton() {
        viewModel.action(.save)
    }
    
    // 수정할 프로필 이미지 선택
    func didSelectImage(url: String) {
        viewModel.action(.changeProfileImage(url: url))
        // 저장 버튼 상태 업데이트
        updateSaveButtonState()
    }
    
    // 이름 텍스트필드 내용 수정
    @objc func didChangeNameTextField() {
        // 공백 문자 제거
        let rawText = customView.nameTextField.text ?? ""
        let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        customView.nameTextField.text = trimmedText
        
        // ViewModel에 Input 전달
        viewModel.action(.changeUserName(name: customView.nameTextField.text ?? ""))
        
        // 저장 버튼 상태 업데이트
        updateSaveButtonState()
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Output을 UI에 반영
    func apply(_ output: ProfileEditingViewModel.Output) {
        // 로딩 상태 반영
        switch output.isLoading {
        case .loading(for: let text):
            // 전달 받은 로딩 메세지를 반영하여 로딩 뷰 표시
            customView.loadingView.startLoading(with: text)
        case .notLoading:
            customView.loadingView.stopLoading()
        }
        
        // UI 업데이트
        customView.profileImageView.kf.setImage(with: URL(string: output.profileImageUrl ?? ""), placeholder: UIImage(systemName: "person.crop.circle"))
        customView.nameTextField.text = output.userName
    }
}

// MARK: - UITextFieldDelegate
extension ProfileEditingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
