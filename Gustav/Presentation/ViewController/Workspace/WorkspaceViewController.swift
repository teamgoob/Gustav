//
//  WorkspaceViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import UIKit

// MARK: - WorkspaceViewController
final class WorkspaceViewController: UIViewController {
    // MARK: - Properties
    // 뷰 & 뷰 모델
    private let customView = WorkspaceView()
    private let viewModel: WorkspaceViewModel
    // 워크스페이스 설정 버튼
    private lazy var workspaceSettingButton = UIBarButtonItem(
        image: UIImage(systemName: "gearshape.fill"),
        style: .plain,
        target: self,
        action: #selector(didTapSettingButton)
    )
    
    // MARK: - Initializer
    init(viewModel: WorkspaceViewModel) {
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
        // 뷰 모델에 화면 표시 이벤트 전달
        viewModel.action(.viewDidAppear)
    }
}

// MARK: - Setup
private extension WorkspaceViewController {
    // Navigation Item 설정
    func setupNavigationItem() {
        // 네비게이션 타이틀 설정
        navigationItem.title = "Workspace"
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
        
        // 네비게이션 바 우측 워크스페이스 설정 버튼 설정
        navigationItem.rightBarButtonItem = workspaceSettingButton
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

// MARK: - Event Handling & Output Apply Method
private extension WorkspaceViewController {
    // Output을 UI에 반영
    func apply(_ output: WorkspaceViewModel.Output) {
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
        
        // 테이블 뷰 업데이트
        // Output Action에 따라 테이블 뷰 갱신
        switch output.action {
        // 테이블 전체 다시 불러오기
        case .reloadData:
            customView.tableView.reloadData()
        // 특정 셀 다시 불러오기 (셀 확장 버튼 입력 시)
        case .reloadCell(let index):
            let indexPath = IndexPath(row: index, section: 0)
            customView.tableView.performBatchUpdates {
                customView.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        // 특정 갯수의 셀 추가하기 (다음 페이지 불러오기 시)
        case .insertRows(let offsets):
            let indexPaths = (offsets.0..<offsets.1).map {
                IndexPath(row: $0, section: 0)
            }
            customView.tableView.performBatchUpdates {
                customView.tableView.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
    
    // 워크스페이스 설정 버튼 선택 시 호출
    @objc func didTapSettingButton() {
        viewModel.action(.toWorkspaceSettings)
    }
}

// MARK: - UITableViewDataSource
extension WorkspaceViewController: UITableViewDataSource {
    // 테이블 뷰 아이템 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 테이블 뷰에 아이템이 없는 경우
        if viewModel.tableViewCellDatas.isEmpty {
            return 1
        }
        
        return viewModel.tableViewCellDatas.count
    }
    // 특정 셀의 정보
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 셀 불러오기
        // 테이블 뷰에 아이템이 없는 경우
        if viewModel.tableViewCellDatas.isEmpty {
            guard let cell = customView.tableView.dequeueReusableCell(withIdentifier: EmptyStateCell.identifier, for: indexPath) as? EmptyStateCell else {
                return UITableViewCell()
            }
            return cell
        }
        guard let cell = customView.tableView.dequeueReusableCell(withIdentifier: WorkspaceItemCell.identifier, for: indexPath) as? WorkspaceItemCell else {
            return UITableViewCell()
        }
        
        // 셀 정보 불러오기
        let cellData = viewModel.tableViewCellDatas[indexPath.row]
        // 셀 초기화
        cell.configure(with: cellData)
        // 클로저 할당
        cell.onEditButtonTapped = { [weak self] in
            self?.viewModel.action(.tapEditButton(cellData.id))
        }
        cell.onExpandButtonTapped = { [weak self] in
            self?.viewModel.action(.tapExpandButton(cellData.id))
        }
        
        return cell
    }
    // 셀의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 테이블 뷰에 아이템이 없는 경우
        if viewModel.tableViewCellDatas.isEmpty {
            return customView.tableView.bounds.height / 2
        }
        
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension WorkspaceViewController: UITableViewDelegate {
    // 특정 셀을 표시하기 전에 호출
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 현재 불러온 마지막 직전 셀까지 스크롤한 경우, 다음 페이지 불러오기
        let updateIndex = viewModel.tableViewCellDatas.count - 1
        if indexPath.row == updateIndex {
            viewModel.action(.loadNextPage)
        }
    }
}
