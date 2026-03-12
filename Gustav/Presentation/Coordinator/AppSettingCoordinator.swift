//
//  AppSettingCoordinator.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/12.
//

import UIKit

// MARK: - AppSettingCoordinator
// 앱 설정 코디네이터, Root View: AppSettingView
final class AppSettingCoordinator: Coordinator {
    // MARK: - Properties
    // Navigation Controller
    let navigationController: UINavigationController
    // Child Coordinators
    var childCoordinators: [Coordinator] = []
    // AppSettingDIContainer
    private let container: AppSettingDIContainer
    // Root ViewModel - 프로필 수정 후, 설정 목록으로 돌아올 때 ViewModel 메서드 호출을 위해 참조
    private lazy var appSettingViewModel: AppSettingViewModel = {
        container.makeAppSettingViewModel()
    }()
    
    // MARK: - Closures
    // 부모 Coordinator에게 Flow 종료 알림
    var onFinish: ((Coordinator) -> Void)?
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, container: AppSettingDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    // MARK: - Flow Start
    func start() {
        // 앱 설정 목록 표시
        showAppSettingList()
    }
    
    // MARK: - Flow Finish
    func finish() {
        // 부모 Coordinator에게 Flow 종료 알림
        onFinish?(self)
    }
    
    // MARK: - Deinit Children
    private func removeChild(_ finishedCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === finishedCoordinator }
    }
}

// MARK: - Private Logic
private extension AppSettingCoordinator {
    // 설정 목록 화면 표시
    func showAppSettingList() {
        // VM, VC 선언
        let viewController = AppSettingViewController(viewModel: appSettingViewModel)
        // VM 클로저 전달
        appSettingViewModel.onNavigation = { [weak self] destination in
            switch destination {
            case .dismiss:
                // Root View Pop 시, 코디네이터 해제
                self?.finish()
            case .pushTo(next: let next):
                switch next {
                case .editProfile:
                    self?.showProfileEditor()
                case .appInfo:
                    self?.showAppInfo()
                case .privacyPolicy:
                    self?.showPrivacyPolicy()
                case .signOut:
                    break
                case .deleteAccount:
                    self?.showDeleteAccount()
                }
            case .showAlertForSignOutConfirmation:
                self?.showSignOutAlert()
            case .showAlertToNoticeSignOutFailure:
                self?.showFailureAlert(for: "Failed to sign out.")
            }
        }
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    // 프로필 수정 화면 표시
    func showProfileEditor() {
        // VM, VC 선언
        let viewModel = container.makeProfileEditingViewModel()
        let viewController = ProfileEditingViewController(viewModel: viewModel)
        // VM 클로저 전달
        viewModel.onNavigation = { [weak self] destination in
            switch destination {
            case .dismiss:
                break
            case .dismissAfterSave:
                // 프로필 수정 화면 Pop
                self?.popCurrentViewController()
                // 설정 목록 화면 프로필 다시 불러오기
                self?.appSettingViewModel.action(.profileEdited)
            case .showAlertToNoticeEditingFailure:
                // 프로필 수정 화면 Pop
                self?.popCurrentViewController()
                // 저장 실패 얼럿 창 표시
                self?.showFailureAlert(for: "Failed to save changes.")
            }
        }
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    // 앱 정보 화면 표시
    func showAppInfo() {
        // URL, 제목 입력하여 VC 생성
        let viewController = WebpageViewController(
            urlString: "https://dramatic-snipe-e53.notion.site/Gustav-Application-Information-31f1e18cef9c80e4a6b6e36bddc464ac",
            title: "Application Information"
        )
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    // 개인 정보 처리 방침 화면 표시
    func showPrivacyPolicy() {
        // URL, 제목 입력하여 VC 생성
        let viewController = WebpageViewController(
            urlString: "https://dramatic-snipe-e53.notion.site/Gustav-Privacy-Policy-31f1e18cef9c801fb1d4c45cbc7ab321",
            title: "Privacy Policy"
        )
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    // 로그아웃 얼럿 창 표시
    func showSignOutAlert() {
        // 얼럿 창 생성
        let alert = UIAlertController(
            title: "Sign out",
            message: "Are you sure you want to sign out from Gustav?",
            preferredStyle: .alert
        )
        // 취소 버튼 생성
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        // 확인 버튼 생성
        let signOutAction = UIAlertAction(
            title: "Sign out",
            style: .default
        ) { [weak self] _ in
            self?.appSettingViewModel.action(.confirmSignOut)
        }
        // 버튼 추가
        alert.addAction(cancelAction)
        alert.addAction(signOutAction)
        // 얼럿 창 표시
        navigationController.visibleViewController?.present(alert, animated: true)
    }
    // 회원 탈퇴 화면 표시
    func showDeleteAccount() {
        // VM, VC 선언
        let viewModel = container.makeAccountDeletingViewModel()
        let viewController = AccountDeletingViewController(viewModel: viewModel)
        // VM 클로저 전달
        viewModel.onNavigation = { [weak self] destination in
            switch destination {
            case .dismiss:
                break
            case .showAlertToNoticeDeleteAccountFailure:
                // 회원 탈퇴 화면 Pop
                self?.popCurrentViewController()
                // 실패 얼럿 창 표시
                self?.showFailureAlert(for: "Failed to delete your account. Please try again later.")
            }
        }
        // 화면 전환
        navigationController.pushViewController(viewController, animated: true)
    }
    // 실패 얼럿 창 표시
    func showFailureAlert(for message: String) {
        // 얼럿 창 생성
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        // 확인 버튼 생성
        let confirmAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        // 버튼 추가
        alert.addAction(confirmAction)
        // 얼럿 창 표시
        navigationController.visibleViewController?.present(alert, animated: true)
    }
    // 현재 화면 Pop
    func popCurrentViewController() {
        navigationController.popViewController(animated: true)
    }
}
