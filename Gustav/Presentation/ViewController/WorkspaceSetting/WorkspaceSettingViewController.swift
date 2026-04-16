//
//  WorkspaceSettingViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/20.
//

import UIKit

// MARK: - WorkspaceSettingViewController
final class WorkspaceSettingViewController: UIViewController {
    // MARK: - Properties
    // 뷰 & 뷰 모델
    private let customView = WorkspaceSettingView()
    private let viewModel: WorkspaceSettingViewModel
    
    // MARK: - Initializer
    init(viewModel: WorkspaceSettingViewModel) {
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
        setupDelegate()
        bindViewModel()
        
        customView.tableView.reloadData()
        viewModel.action(.viewDidLoad)
    }
    
    // ViewController Pop 이벤트 전달
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            viewModel.action(.dismiss)
        }
    }
    
    // 화면이 표시된 후 호출
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // navigationBar 전체 높이 재계산, 스크롤 위치가 꼬이지 않도록 함
        navigationController?.navigationBar.sizeToFit()
    }
}

// MARK: - Setup
private extension WorkspaceSettingViewController {
    // Navigation Item 설정
    func setupNavigationItem() {
        // 네비게이션 타이틀 설정
        navigationItem.title = "Workspace Settings"
        // Large Title 설정
        navigationItem.largeTitleDisplayMode = .always
        
        // Subtitle 공간 계산을 위해 임시 값으로 공간 확보
        var subtitle = AttributedString("Workspace Name")
        // Large Title 하단에 표시되는 Large Subtitle 텍스트 설정
        subtitle.font = Fonts.accent
        subtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = subtitle
        // 스크롤 시 상단 Title 하단에 표시되는 Subtitle 텍스트 설정
        subtitle.font = Fonts.additional
        navigationItem.attributedSubtitle = subtitle
    }
    
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
private extension WorkspaceSettingViewController {
    // Output을 UI에 반영
    func apply(_ output: WorkspaceSettingViewModel.Output) {
        // 로딩 상태 반영
        switch output.isLoading {
        case .loading(for: let text):
            // 전달 받은 로딩 메세지를 반영하여 로딩 뷰 표시
            customView.loadingView.startLoading(with: text)
        case .notLoading:
            customView.loadingView.stopLoading()
        }
        
        // UI 업데이트
        // 워크스페이스 이름 표시
        var subtitle = AttributedString(output.workspaceName)
        // Large Title 하단에 표시되는 Large Subtitle 텍스트 설정
        subtitle.font = Fonts.accent
        subtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = subtitle
        // 스크롤 시 상단 Title 하단에 표시되는 Subtitle 텍스트 설정
        subtitle.font = Fonts.additional
        navigationItem.attributedSubtitle = subtitle
    }
}

// MARK: - UITableViewDataSource
extension WorkspaceSettingViewController: UITableViewDataSource {
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
        guard let cell = customView.tableView.dequeueReusableCell(withIdentifier: WorkspaceSettingTableCell.identifier, for: indexPath) as? WorkspaceSettingTableCell else {
            return UITableViewCell()
        }
        
        // 셀 정보 불러오기
        let item = viewModel.rowItem(section: indexPath.section, row: indexPath.row)
        
        // 셀 초기화
        switch item {
        case .categorySettings:
            cell.configure(icon: Icons.category, title: "Category settings")
        case .setCategoriesInBulk:
            cell.configure(icon: Icons.bulk, title: "Set categories in bulk")
        case .locationSettings:
            cell.configure(icon: Icons.location, title: "Location settings")
        case .setLocationsInBulk:
            cell.configure(icon: Icons.bulk, title: "Set locations in bulk")
        case .itemStateSettings:
            cell.configure(icon: Icons.itemState, title: "Item state settings")
        case .setItemStatesInBulk:
            cell.configure(icon: Icons.bulk, title: "Set item states in bulk")
        case .viewPresetSettings:
            cell.configure(icon: Icons.viewPreset, title: "View preset settings")
        case .deleteWorkspace:
            cell.configure(icon: Icons.delete, title: "Delete this workspace", titleColor: Colors.Text.red)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WorkspaceSettingViewController: UITableViewDelegate {
    // 테이블 뷰 셀 선택 시 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.rowItem(section: indexPath.section, row: indexPath.row)
        viewModel.action(.didSelectSettingListItem(item))
    }
}
