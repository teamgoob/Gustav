//
//  WorkSpaceSelectionViewController.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit

final class ItemStateListViewController: UIViewController {
    private let contentView = ItemStateListView()
    private let loadingView = LoadingView()
    private let viewModel: ItemStateListViewModel
    private var editorMode: EditorMode = .viewing

    private enum EditorMode {
        case viewing
        case reordering
    }

    // 초기화
    init(viewModel: ItemStateListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // 첫 진입
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
        configureToolbar()
        bindViewModel()
        refreshInterface(reloadData: false)
        viewModel.action(.viewDidLoad)
    }

    // 화면 복귀
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshInterface(reloadData: false)
    }

    // 화면 종료
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            viewModel.action(.dismiss)
        }
    }

    // 코더 초기화
    required init?(coder: NSCoder) {
        fatalError()
    }

    // 뷰 구성
    private func configureView() {
        view = contentView
        view.addSubview(loadingView)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "ItemState"
        navigationItem.largeTitleDisplayMode = .always
        applySubtitle("ItemState")
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // 테이블 구성
    private func configureTableView() {
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(
            ItemAttributeBasicCell.self,
            forCellReuseIdentifier: ItemAttributeBasicCell.reuseID
        )
        contentView.tableView.register(
            ItemAttributeReorderingCell.self,
            forCellReuseIdentifier: ItemAttributeReorderingCell.reuseID
        )
    }

    // 툴바 구성
    private func configureToolbar() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )

        toolbarItems = [UIBarButtonItem.flexibleSpace(), addButton]
    }

    // 상태 바인딩
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading(let isLoading):
                self.applyLoading(isLoading)
            case .subTitle(let subtitle):
                self.applySubtitle(subtitle)
            case .itemStatesChanged:
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

    // 서브타이틀 적용
    private func applySubtitle(_ subtitle: String) {
        var largeSubtitle = AttributedString(subtitle)
        largeSubtitle.font = Fonts.accent
        largeSubtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = largeSubtitle

        var compactSubtitle = AttributedString(subtitle)
        compactSubtitle.font = Fonts.additional
        compactSubtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.attributedSubtitle = compactSubtitle
    }

    // 화면 반영
    private func refreshInterface(reloadData: Bool = true) {
        contentView.tableView.isEditing = (editorMode == .reordering)
        configureNavigationItems()
        updateToolbarVisibility()

        if reloadData {
            reloadTableView()
        }
    }

    // 모드 변경
    private func updateEditorMode(_ mode: EditorMode) {
        editorMode = mode
        refreshInterface()
    }

    // 네비게이션 버튼
    private func configureNavigationItems() {
        switch editorMode {
        case .viewing:
            navigationItem.rightBarButtonItems = [makeMenuButton()]
        case .reordering:
            navigationItem.rightBarButtonItems = [makeDoneButton()]
        }
    }

    // 메뉴 버튼
    private func makeMenuButton() -> UIBarButtonItem {
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: nil,
            action: nil
        )

        menuButton.menu = makeItemStateMenu()
        return menuButton
    }

    // 상태 메뉴
    private func makeItemStateMenu() -> UIMenu {
        UIMenu(children: [
            UIAction(
                title: "Change Order",
                image: UIImage(systemName: "arrow.up.arrow.down")
            ) { [weak self] _ in
                self?.updateEditorMode(.reordering)
            }
        ])
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

    // 툴바 표시
    private func updateToolbarVisibility() {
        navigationController?.setToolbarHidden(editorMode != .viewing, animated: false)
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

    // 기본 셀
    private func makeItemStateCell(
        tableView: UITableView,
        indexPath: IndexPath,
        itemState: ItemState
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemAttributeBasicCell.reuseID,
            for: indexPath
        ) as! ItemAttributeBasicCell

        cell.configure(title: itemState.name, tagColor: itemState.color)
        return cell
    }

    // 정렬 셀
    private func makeReorderingCell(
        tableView: UITableView,
        indexPath: IndexPath,
        itemState: ItemState
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemAttributeReorderingCell.reuseID,
            for: indexPath
        ) as! ItemAttributeReorderingCell

        cell.configure(title: itemState.name, tagColor: itemState.color)
        return cell
    }
}

// MARK: - OBJC 메서드
extension ItemStateListViewController {

    // 완료 탭
    @objc private func didTapDoneButton() {
        guard editorMode == .reordering else { return }
        viewModel.action(.didTapreorderItemStateButton)
        updateEditorMode(.viewing)
    }

    // 추가 탭
    @objc private func didTapAddButton() {
        viewModel.action(.didTapAddButton)
    }
}

// MARK: - UITableViewDataSource
extension ItemStateListViewController: UITableViewDataSource {

    // 행 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemState = viewModel.cellForRowAt(index: indexPath.row)

        switch editorMode {
        case .viewing:
            return makeItemStateCell(tableView: tableView, indexPath: indexPath, itemState: itemState)
        case .reordering:
            return makeReorderingCell(tableView: tableView, indexPath: indexPath, itemState: itemState)
        }
    }

    // 이동 가능
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        editorMode == .reordering
    }

    // 순서 이동
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        viewModel.action(.didReOrderItemState(at: sourceIndexPath.row, to: destinationIndexPath.row))
    }
}

// MARK: - UITableViewDelegate
extension ItemStateListViewController: UITableViewDelegate {

    // 행 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard editorMode == .viewing else { return }
        viewModel.action(.didSelectTapItemState(index: indexPath.row))
    }

    // 편집 스타일
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        editorMode == .reordering ? .none : .delete
    }

    // 삭제 커밋
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editorMode == .viewing, editingStyle == .delete else { return }
        viewModel.action(.deleteItemState(index: indexPath.row))
    }
}
