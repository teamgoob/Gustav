//
//  WorkSpaceSelectionViewController.swift
//  Gustav
//
//  Created by 박선린 on 3/1/26.
//

import UIKit
import SnapKit

class CategoryListViewController: UIViewController {
    private let contentView = CategoryListView()  // 기본 뷰에 사용할 뷰
    private let loadingView = LoadingView()             // 로딩뷰
    private let viewModel: CategoryListViewModel  // 뷰모델
    private var cellMode: cellMode = .normal            // 현재 셀 모드

    // 셀 모드
    private enum cellMode {
        case normal
        case addWorkSpace
        case changeOrder
    }
    
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        set()
        setNavigationButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.action(.dismiss)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setUI() {
        view = contentView
        view.addSubview(loadingView)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Category"
        navigationItem.largeTitleDisplayMode = .always
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func set() {
        // 1) table 설정
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(ItemAttributeBasicCell.self, forCellReuseIdentifier: ItemAttributeBasicCell.reuseID)
        contentView.tableView.register(ItemAttributeReorderingCell.self, forCellReuseIdentifier: ItemAttributeReorderingCell.reuseID)
        
        
        // 2) VM 바인딩
        bindViewModel()

        // 3) 데이터 요청
        viewModel.action(.viewDidLoad)
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )

        toolbarItems = [UIBarButtonItem.flexibleSpace(), addButton]
        navigationController?.isToolbarHidden = false
        
    }
    
    
    // 네비게이션바 버튼 설정
    private func setNavigationButton() {
        switch self.cellMode {
        case .normal, .addWorkSpace:
            let menuButton = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: nil,
                action: nil
            )
            let menu = UIMenu(children: [
                UIAction(
                    title: "Change Order",
                    image: UIImage(systemName: "arrow.up.arrow.down")
                ) { _ in
                    print("Change Order")
                    self.changeCellMode(mode: .changeOrder)
                }
            ])

            menuButton.menu = menu

            navigationItem.rightBarButtonItems = [menuButton]
        
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
            case .subTitle(let subtitle):
                changeSubTitle(subtitle: subtitle)
            }
        }
    }
    
    private func changeSubTitle(subtitle: String) {
        // UI 업데이트
        var subtitle = AttributedString(subtitle)
        // Large Title 하단에 표시되는 Large Subtitle 텍스트 설정
        subtitle.font = Fonts.accent
        subtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = subtitle
        // 스크롤 시 상단 Title 하단에 표시되는 Subtitle 텍스트 설정
        subtitle.font = Fonts.additional
        navigationItem.attributedSubtitle = subtitle

    }
    
    private func changeCellMode(mode: cellMode) {
        self.cellMode = mode
        if self.cellMode == .changeOrder {
            contentView.tableView.isEditing = true
        } else {
            contentView.tableView.isEditing = false
        }
        setNavigationButton()
        self.tableViewReload()
    }
    
    @objc private func endButtonTapped() {
        switch self.cellMode {
        case .normal:
            break
        case .addWorkSpace:
            break
        case .changeOrder:
            self.viewModel.action(.didTapreorderCategoryButton)
            changeCellMode(mode: .normal)
        }
    }
    
    @objc private func didTapAddButton() {
        self.viewModel.action(.didTapAddButton)
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
extension CategoryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = viewModel.cellForRowAt(index: indexPath.row)
        switch self.cellMode {
        case .normal, .addWorkSpace:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ItemAttributeBasicCell.reuseID,
                for: indexPath
            ) as! ItemAttributeBasicCell
            
            cell.configure(title: category.name, tagColor: category.color)
            return cell
            
        case .changeOrder:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ItemAttributeReorderingCell.reuseID,
                for: indexPath
            ) as! ItemAttributeReorderingCell
            
            cell.configure(title: category.name, tagColor: category.color)
            
            return cell
        }
    }
    
    // 이 row가 이동 가능한지 여부를 반환합니다.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // 사용자가 row를 이동했을 때 원본 배열 순서를 변경합니다.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.action(.didReOrderCategories(at: sourceIndexPath.row, to: destinationIndexPath.row))
    }
}

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard self.cellMode == .normal else { return } // 편집모드면 이동
        viewModel.action(.didSelectTapCategory(index: indexPath.row))
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .insert
    }
}
