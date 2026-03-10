//
//  WorkSpaceSelectionViewController.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit
class WorkSpaceSelectionViewController: UIViewController {
    private let contentView = WorkSpaceSelectionView()  // 기본 뷰에 사용할 뷰
    private let loadingView = LoadingView()             // 로딩뷰
    private let viewModel: WorkSpaceSelectionViewModel  // 뷰모델
    private var cellMode: cellMode = .normal            // 현재 셀 모드

    // 셀 모드
    private enum cellMode {
        case normal
        case addWorkSpace
        case changeName
        case changeOrder
    }
    
    init(viewModel: WorkSpaceSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        set()
        setNavigationButton()
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
        contentView.tableView.register(WorkSpaceSelectionTableViewCell.self, forCellReuseIdentifier: WorkSpaceSelectionTableViewCell.reuseID)
        contentView.tableView.register(WorkspaceNameEditCell.self, forCellReuseIdentifier: WorkspaceNameEditCell.reuseID)
        contentView.tableView.register(WorkSpaceReorderCell.self, forCellReuseIdentifier: WorkSpaceReorderCell.reuseID)
        
        
        // 2) VM 바인딩
        bindViewModel()

        // 3) 데이터 요청
        viewModel.action(.viewDidLoad)
        
        
    }
    
    // 네비게이션바 설정
    private func setNavigationButton() {
        switch self.cellMode {
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
                ) { _ in
                    print("Add WorkSpace")
                    self.presentAddWorkspaceAlert()
                    
                },
                UIAction(
                    title: "Change Order",
                    image: UIImage(systemName: "arrow.up.arrow.down")
                ) { _ in
                    print("Change Order")
                    self.changeCellMode(mode: .changeOrder)
                },
                UIAction(
                    title: "Change Name",
                    image: UIImage(systemName: "square.and.pencil")
                ) { _ in
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
            case .data:
                self.contentView.tableView.reloadData()
                
            case .success:
                self.contentView.tableView.reloadData()
            case .error(let message):
                print("error:", message)
            
            case .profile(urlstring: let urlstring, name: let name):
                contentView.updateProfile(imageUrl: urlstring, name: name)
            }
        }
        
        // 화면 관련
        viewModel.onNavigation = { [weak self] route in
            guard let self else { return }
            
            switch route {
            case .pushToWorkspaceDetail(let workspace):
                // 임시
                print("워크스페이스 자세히 보기")
            case .presentCreateWorkspace:
                // 임시
                print("새로운 워크스페이스 생성하기")
            case .showErrorAlert(let message):
                //임시
                print("에러가 발생했어요")
            case .pushToAppSetting:
                // 임시
                print("앱설정화면으로 이동")
                let tempASVC = AppSettingViewController(viewModel: AppSettingViewModel(authUsecase: TestAuthUsecase(), profileUsecase: TestProfileUsecase()))
                navigationController?.pushViewController(tempASVC, animated: true)
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
    }
    
    @objc private func endButtonTapped() {
        switch self.cellMode {
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
    
    
    private func presentAddWorkspaceAlert() {
        let alert = UIAlertController(
            title: "Add WorkSpace",
            message: "새로운 워크스페이스 이름을 입력해주세요",
            preferredStyle: .alert)

        alert.addTextField { tf in
            tf.placeholder = "예: 개인 / 회사 / 프로젝트"
            tf.clearButtonMode = .whileEditing
            tf.autocapitalizationType = .none
            tf.returnKeyType = .done
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel)

        let add = UIAlertAction(title: "추가", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else {
                self.viewModel.action(.didTapAddWorkspaceButton(name: "새 워크스페이스"))
                return
            }

            self.viewModel.action(.didTapAddWorkspaceButton(name: name))
        }

        alert.addAction(cancel)
        alert.addAction(add)

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension WorkSpaceSelectionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.workSpaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workspace = viewModel.workSpaces[indexPath.row]
        switch self.cellMode {
        case .normal:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkSpaceSelectionTableViewCell.reuseID,
                for: indexPath
            ) as! WorkSpaceSelectionTableViewCell
            
            cell.configure(
                title: workspace.name,
                updatedAt: workspace.updatedAt)
            return cell
            
        
        case .addWorkSpace:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkSpaceSelectionTableViewCell.reuseID,
                for: indexPath
            ) as! WorkSpaceSelectionTableViewCell
            
            cell.configure(
                title: workspace.name,
                updatedAt: workspace.updatedAt)
            return cell
            
            
        case .changeName:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: WorkspaceNameEditCell.reuseID,
                for: indexPath
            ) as! WorkspaceNameEditCell
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
                withIdentifier: WorkSpaceReorderCell.reuseID,
                for: indexPath
            ) as! WorkSpaceReorderCell
            
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

extension WorkSpaceSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let workspace = viewModel.workSpaces[indexPath.row]
        guard self.cellMode == .normal else { return } // 편집모드면 이동 X
        viewModel.action(.didSelectTapWorkspace(index: indexPath.row))
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .none
    }
}
