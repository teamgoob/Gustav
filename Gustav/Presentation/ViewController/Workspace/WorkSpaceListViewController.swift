//
//  WorkSpaceSelectionViewController.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit

final class WorkSpaceListViewController: UIViewController {
    private let contentView = WorkSpaceListView()
    private let loadingView = LoadingView()
    private let viewModel: WorkSpaceListViewModel
    private var editorMode: EditorMode = .viewing

    private enum EditorMode {
        case viewing
        case renaming
        case reordering
    }

    private var isEmptyState: Bool {
        viewModel.isWorkspaceListEmpty
    }

    // 초기화
    init(viewModel: WorkSpaceListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // 첫 진입
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
        bindViewModel()
        viewModel.action(.viewDidLoad)
    }

    // 화면 복귀
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(.reFetchProfile)
    }

    // 코더 초기화
    required init?(coder: NSCoder) {
        fatalError()
    }

    // 뷰 구성
    private func configureView() {
        view = contentView
        view.addSubview(loadingView)
        // 다음 화면의 뒤로 가기 목록에 표시할 타이틀 설정
        navigationItem.backButtonTitle = "Home"
        // 뒤로 가기 버튼 자체에 타이틀이 표시되지는 않도록 설정
        navigationItem.backButtonDisplayMode = .minimal

        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // 테이블 구성
    private func configureTableView() {
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(
            WorkSpaceTableViewBasicCell.self,
            forCellReuseIdentifier: WorkSpaceTableViewBasicCell.reuseID
        )
        contentView.tableView.register(
            WorkspaceNameEditingCell.self,
            forCellReuseIdentifier: WorkspaceNameEditingCell.reuseID
        )
        contentView.tableView.register(
            WorkSpaceReorderingCell.self,
            forCellReuseIdentifier: WorkSpaceReorderingCell.reuseID
        )
        contentView.tableView.register(
            EmptyWorkspaceTableViewCell.self,
            forCellReuseIdentifier: EmptyWorkspaceTableViewCell.reuseID
        )
    }

    // 상태 바인딩
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading(let isLoading):
                self.applyLoading(isLoading)
            case .profile(let urlString, let name):
                self.contentView.updateProfile(imageUrl: urlString, name: name)
            case .workspacesChanged:
                self.refreshInterface()
            }
        }
    }

    // 로딩 적용
    private func applyLoading(_ isLoading: Bool) {
        switch isLoading {
        case true:
            loadingView.startLoading()
        case false:
            loadingView.stopLoading()
        }
    }

    // 화면 반영
    private func refreshInterface() {
        if isEmptyState {
            editorMode = .viewing
        }

        contentView.tableView.isEditing = (editorMode == .reordering)
        configureNavigationItems()
        reloadTableView()
    }

    // 모드 변경
    private func updateEditorMode(_ mode: EditorMode) {
        editorMode = isEmptyState ? .viewing : mode
        refreshInterface()
    }

    // 네비게이션 버튼
    private func configureNavigationItems() {
        switch (isEmptyState, editorMode) {
        case (true, _):
            navigationItem.rightBarButtonItems = [makeSettingButton(), makeAddButton()]
        case (false, .viewing):
            navigationItem.rightBarButtonItems = [makeSettingButton(), makeMenuButton()]
        case (false, .renaming), (false, .reordering):
            navigationItem.rightBarButtonItems = [makeDoneButton()]
        }
    }

    // 설정 버튼
    private func makeSettingButton() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapSettingButton)
        )
    }

    // 추가 버튼
    private func makeAddButton() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddWorkspaceButton)
        )
    }

    // 메뉴 버튼
    private func makeMenuButton() -> UIBarButtonItem {
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: nil,
            action: nil
        )

        menuButton.menu = makeWorkspaceMenu()
        return menuButton
    }

    // 완료 버튼
    private func makeDoneButton() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .plain,
            target: self,
            action: #selector(didTapDoneButton)
        )
    }

    // 일반 메뉴
    private func makeWorkspaceMenu() -> UIMenu {
        UIMenu(children: [
            UIAction(
                title: "Add WorkSpace",
                image: UIImage(systemName: "plus")
            ) { [weak self] _ in
                self?.viewModel.action(.didTapAddWorkspaceButton)
            },
            UIAction(
                title: "Change Order",
                image: UIImage(systemName: "arrow.up.arrow.down")
            ) { [weak self] _ in
                self?.updateEditorMode(.reordering)
            },
            UIAction(
                title: "Change Name",
                image: UIImage(systemName: "square.and.pencil")
            ) { [weak self] _ in
                self?.updateEditorMode(.renaming)
            }
        ])
    }

    // 테이블 갱신
    private func reloadTableView() {
        UIView.transition(
            with: contentView.tableView,
            duration: 0.20,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.contentView.tableView.reloadData()
        }
    }

    // 빈 셀
    private func makeEmptyCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(
            withIdentifier: EmptyWorkspaceTableViewCell.reuseID,
            for: indexPath
        ) as! EmptyWorkspaceTableViewCell
    }

    // 일반 셀
    private func makeBasicCell(
        tableView: UITableView,
        indexPath: IndexPath,
        workspace: Workspace
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: WorkSpaceTableViewBasicCell.reuseID,
            for: indexPath
        ) as! WorkSpaceTableViewBasicCell

        cell.configure(title: workspace.name, updatedAt: workspace.updatedAt)
        return cell
    }

    // 이름 편집 셀
    private func makeEditingCell(
        tableView: UITableView,
        indexPath: IndexPath,
        workspace: Workspace
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: WorkspaceNameEditingCell.reuseID,
            for: indexPath
        ) as! WorkspaceNameEditingCell

        cell.configure(title: workspace.name, updatedAt: workspace.updatedAt)
        cell.onTextChanged = { [weak self, weak tableView, weak cell] newText in
            guard let self,
                  let tableView,
                  let cell,
                  let currentIndexPath = tableView.indexPath(for: cell)
            else { return }

            self.viewModel.updateText(index: currentIndexPath.row, text: newText)
        }

        return cell
    }

    // 순서 편집 셀
    private func makeReorderingCell(
        tableView: UITableView,
        indexPath: IndexPath,
        workspace: Workspace
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: WorkSpaceReorderingCell.reuseID,
            for: indexPath
        ) as! WorkSpaceReorderingCell

        cell.configure(title: workspace.name)
        return cell
    }
}

// MARK: - OBJC 메서드
extension WorkSpaceListViewController {

    // 설정 이동
    @objc private func didTapSettingButton() {
        viewModel.action(.didTapAppSetting)
    }

    // 추가 요청
    @objc private func didTapAddWorkspaceButton() {
        viewModel.action(.didTapAddWorkspaceButton)
    }

    // 편집 완료
    @objc private func didTapDoneButton() {
        switch editorMode {
        case .viewing:
            break
        case .renaming:
            viewModel.action(.didTapupdateWorkspacesNameButton)
            updateEditorMode(.viewing)
        case .reordering:
            viewModel.action(.didTapreorderWorkspacesButton)
            updateEditorMode(.viewing)
        }
    }
}

// MARK: - UITableViewDataSource
extension WorkSpaceListViewController: UITableViewDataSource {

    // 행 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isEmptyState ? 1 : viewModel.workSpaces.count
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !isEmptyState else {
            return makeEmptyCell(tableView: tableView, indexPath: indexPath)
        }

        let workspace = viewModel.workSpaces[indexPath.row]

        switch editorMode {
        case .viewing:
            return makeBasicCell(tableView: tableView, indexPath: indexPath, workspace: workspace)
        case .renaming:
            return makeEditingCell(tableView: tableView, indexPath: indexPath, workspace: workspace)
        case .reordering:
            return makeReorderingCell(tableView: tableView, indexPath: indexPath, workspace: workspace)
        }
    }

    // 이동 가능
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        !isEmptyState && editorMode == .reordering
    }

    // 순서 이동
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        viewModel.action(.didReOrderWorkspaces(at: sourceIndexPath.row, to: destinationIndexPath.row))
    }
}

// MARK: - UITableViewDelegate
extension WorkSpaceListViewController: UITableViewDelegate {

    // 행 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard !isEmptyState, editorMode == .viewing else { return }
        viewModel.action(.didSelectTapWorkspace(index: indexPath.row))
    }

    // 편집 스타일
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        .none
    }
}
