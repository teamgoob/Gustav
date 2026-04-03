//
//  WorkSpaceSelectionViewController.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit
class WorkSpaceListViewController: UIViewController {
    private let contentView = WorkSpaceListView()  // 기본 뷰에 사용할 뷰
    private let loadingView = LoadingView()             // 로딩뷰
    private let viewModel: WorkSpaceListViewModel  // 뷰모델
    private var cellMode: cellMode = .normal            // 현재 셀 모드

    // 셀 모드
    private enum cellMode {
        case emptyWorkspace
        case normal
        case addWorkSpace
        case changeName
        case changeOrder
    }
    
    init(viewModel: WorkSpaceListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        set()
        setNavigationButton()
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.action(.reFetchProfile)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setUI() {
        view = contentView
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    private func set() {
        // table 설정
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(WorkSpaceTableViewBasicCell.self, forCellReuseIdentifier: WorkSpaceTableViewBasicCell.reuseID)
        contentView.tableView.register(WorkspaceNameEditingCell.self, forCellReuseIdentifier: WorkspaceNameEditingCell.reuseID)
        contentView.tableView.register(WorkSpaceReorderingCell.self, forCellReuseIdentifier: WorkSpaceReorderingCell.reuseID)
        contentView.tableView.register(EmptyWorkspaceTableViewCell.self, forCellReuseIdentifier: EmptyWorkspaceTableViewCell.reuseID)
        
        
        // 2) VM 바인딩
        bindViewModel()

        // 3) 데이터 요청
        viewModel.action(.viewDidLoad)
        
        
    }
    
    // 네비게이션바 설정
    private func setNavigationButton() {
        switch self.cellMode {
        case .emptyWorkspace:
            let plusButton = UIBarButtonItem(
                image: UIImage(systemName: "plus"),
                style: .plain,
                target: nil,
                action: #selector(didTapAddWorkspaceButton)
            )

            let setButton = UIBarButtonItem(
                image: UIImage(systemName: "gearshape.fill"),
                style: .plain,
                target: self,
                action: #selector(didTapSettingButton)
            )
            navigationItem.rightBarButtonItems = [setButton, plusButton]
            
        case .normal:
            let menuButton = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: nil,
                action: nil
            )

            let setButton = UIBarButtonItem(
                image: UIImage(systemName: "gearshape.fill"),
                style: .plain,
                target: self,
                action: #selector(didTapSettingButton)
            )

            let menu = UIMenu(children: [
                
                UIAction(
                    title: "Add WorkSpace",
                    image: UIImage(systemName: "plus")
                ) { [weak self] _ in
                    guard let self else { return }
                    print("Add WorkSpace")
                    self.viewModel.action(.didTapAddWorkspaceButton)
                },
                UIAction(
                    title: "Change Order",
                    image: UIImage(systemName: "arrow.up.arrow.down")
                ) { [weak self] _ in
                    guard let self else { return }
                    print("Change Order")
                    self.changeCellMode(mode: .changeOrder)
                },
                UIAction(
                    title: "Change Name",
                    image: UIImage(systemName: "square.and.pencil")
                ) { [weak self] _ in
                    guard let self else { return }
                    print("Change Name")
                    self.changeCellMode(mode: .changeName)
                }
            ])

            menuButton.menu = menu

            navigationItem.rightBarButtonItems = [setButton, menuButton]
            
        case .addWorkSpace:
            navigationItem.rightBarButtonItems = nil
            let endButton = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(endButtonTapped)
            )
            navigationItem.rightBarButtonItems = [endButton]
            
        case .changeName:
            navigationItem.rightBarButtonItems = nil
            let endButton = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(endButtonTapped)
            )
            navigationItem.rightBarButtonItems = [endButton]
        
        case .changeOrder:
            navigationItem.rightBarButtonItems = nil
            let endButton = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(endButtonTapped)
            )
            navigationItem.rightBarButtonItems = [endButton]
        }
        
    }
    
    private func bindViewModel() {
        // 데이터 관련
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading(let isLoading):
                switch isLoading {
                case true:
                    self.loadingView.startLoading()
                case false:
                    self.loadingView.stopLoading()
                }
                
            case .success:
                self.tableViewReload()
                
            case .profile(urlstring: let urlstring, name: let name):
                contentView.updateProfile(imageUrl: urlstring, name: name)
            case .emptyWorkspace:
                self.changeCellMode(mode: .emptyWorkspace)
            }
        }
    }
    
    private func changeCellMode(mode: cellMode) {
        self.cellMode = mode
        if self.cellMode == .changeOrder {
            contentView.tableView.isEditing = true
        } else {
            contentView.tableView.isEditing = false
        }
        setNavigationButton()
        UIView.transition(
            with: contentView.tableView,
            duration: 0.20,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.contentView.tableView.reloadData()
        }
    }
    
    // 설정 버튼(Gear) 클릭시 실행되는 메서드 - 상단 내비바
    @objc private func didTapSettingButton() {
        viewModel.action(.didTapAppSetting)
        changeCellMode(mode: .normal)
    }
    
    @objc private func didTapAddWorkspaceButton() {
        self.viewModel.action(.didTapAddWorkspaceButton)
    }
    
    @objc private func endButtonTapped() {
        switch self.cellMode {
        case .emptyWorkspace:
            break
        case .normal:
            break
        case .addWorkSpace:
            break
        case .changeName:
            self.viewModel.action(.didTapupdateWorkspacesNameButton)
            changeCellMode(mode: .normal)
        case .changeOrder:
            self.viewModel.action(.didTapreorderWorkspacesButton)
            changeCellMode(mode: .normal)
        }
    }
    
    private func tableViewReload() {
        UIView.transition(
            with: contentView.tableView,
            duration: 0.20,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.contentView.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension WorkSpaceListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.cellMode == .emptyWorkspace {
            return 1
        } else {
            return viewModel.workSpaces.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.workSpaces.isEmpty {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EmptyWorkspaceTableViewCell.reuseID, for: indexPath
                ) as! EmptyWorkspaceTableViewCell
            return cell
        }
        let workspace = viewModel.workSpaces[indexPath.row]
        switch self.cellMode {
        case .emptyWorkspace:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EmptyWorkspaceTableViewCell.reuseID, for: indexPath
                ) as! EmptyWorkspaceTableViewCell
            return cell
        case .normal:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkSpaceTableViewBasicCell.reuseID,
                for: indexPath
            ) as! WorkSpaceTableViewBasicCell
            
            cell.configure(
                title: workspace.name,
                updatedAt: workspace.updatedAt)
            return cell
            
        
        case .addWorkSpace:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkSpaceTableViewBasicCell.reuseID,
                for: indexPath
            ) as! WorkSpaceTableViewBasicCell
            
            cell.configure(
                title: workspace.name,
                updatedAt: workspace.updatedAt)
            return cell
            
            
        case .changeName:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkspaceNameEditingCell.reuseID,
                for: indexPath
            ) as! WorkspaceNameEditingCell
            cell.configure(title: workspace.name, updatedAt: workspace.updatedAt)
            
            // 셀이 직접 indexPath를 기억하지 않고,
            // 이벤트 발생 시 현재 셀 위치를 다시 찾아서 ViewModel에 전달합니다.
            cell.onTextChanged = { [weak self, weak tableView, weak cell] newText in
                guard let self,
                      let tableView,
                      let cell,
                      let currentIndexPath = tableView.indexPath(for: cell)
                else { return }

                // 현재 row의 원본 데이터를 ViewModel에서 수정합니다.
                self.viewModel.updateText(index: currentIndexPath.row, text: newText)
            }
            
            return cell
            
        case .changeOrder:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkSpaceReorderingCell.reuseID,
                for: indexPath
            ) as! WorkSpaceReorderingCell
            
            cell.configure(title: workspace.name)
            
            
            return cell
        }
    }
    
    // 이 row가 이동 가능한지 여부를 반환합니다.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // 사용자가 row를 이동했을 때 원본 배열 순서를 변경합니다.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.action(.didReOrderWorkspaces(at: sourceIndexPath.row, to: destinationIndexPath.row))
    }
}

extension WorkSpaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        guard self.cellMode == .normal else { return } // 편집모드면 이동
        viewModel.action(.didSelectTapWorkspace(index: indexPath.row))
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }
}
