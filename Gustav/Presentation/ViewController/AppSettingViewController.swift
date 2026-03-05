//
//  AppSettingViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/4.
//

import UIKit
import Kingfisher

// MARK: - AppSettingViewController
final class AppSettingViewController: UIViewController {
    // MARK: - Properties
    // 뷰 & 뷰 모델
    private let customView = AppSettingView()
    private let viewModel: AppSettingViewModel
    
    // MARK: - Initializer
    init(viewModel: AppSettingViewModel) {
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
        
        // 네비게이션 타이틀 설정
        title = "Setting"
        
        setupDelegate()
        bindViewModel()
        
        customView.tableView.reloadData()
        viewModel.action(.viewDidLoad)
    }
}

// MARK: - Setup
private extension AppSettingViewController {
    // Delegate 설정
    func setupDelegate() {
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
    }
    
    // ViewModel Output 바인딩
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
    }
}

// MARK: - Output Apply Method
private extension AppSettingViewController {
    // Output을 UI에 반영
    func apply(_ output: AppSettingViewModel.Output) {
        print("apply method called")
        // 로딩 상태 반영
        if output.isLoading {
            customView.loadingView.startLoading()
        } else {
            customView.loadingView.stopLoading()
        }
        
        // UI 업데이트
        customView.profileImageView.kf.setImage(with: URL(string: output.profileImageUrl ?? ""), placeholder: UIImage(systemName: "person.crop.circle"))
        if let name = output.userName, !name.isEmpty {
            customView.nameLabel.text = name
        } else {
            customView.nameLabel.text = "-"
        }
        if let email = output.userEmail, !email.isEmpty {
            customView.emailLabel.text = email
        } else {
            customView.emailLabel.text = "-"
        }
    }
}

// MARK: - UITableViewDataSource
extension AppSettingViewController: UITableViewDataSource {
    // 테이블 뷰 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    // 각 섹션 당 아이템 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    // 특정 셀의 정보
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 셀 불러오기
        guard let cell = customView.tableView.dequeueReusableCell(withIdentifier: AppSettingTableCell.identifier, for: indexPath) as? AppSettingTableCell else {
            return UITableViewCell()
        }
        
        // 셀 정보 불러오기
        let item = viewModel.rowItem(section: indexPath.section, row: indexPath.row)
        
        // 셀 초기화
        switch item {
        case .editProfile:
            cell.configure(icon: Icons.profile, title: "Edit Profile")
        case .appInfo:
            cell.configure(icon: Icons.info, title: "Application Information")
        case .privacyPolicy:
            cell.configure(icon: Icons.policy, title: "Privacy Policy")
        case .signOut:
            cell.configure(icon: Icons.signOut, title: "Sign Out")
        case .deleteAccount:
            cell.configure(icon: Icons.delete, title: "Delete My Account", titleColor: Colors.Theme.red)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AppSettingViewController: UITableViewDelegate {
    // 테이블 뷰 셀 선택 시 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.rowItem(section: indexPath.section, row: indexPath.row)
        viewModel.action(.didSelectSettingListItem(item))
    }
}
