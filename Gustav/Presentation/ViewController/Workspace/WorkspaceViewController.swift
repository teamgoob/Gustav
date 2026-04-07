//
//  WorkspaceViewController.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import UIKit
import SnapKit

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
    // 프리셋, 정렬, 필터 적용 버튼
    private let queryOptionMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        button.tintColor = Colors.Text.main
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    // 하단 툴바
    private let bottomToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        return toolbar
    }()
    // 하단 검색창
    private let searchBarItem: UIBarButtonItem = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search items by name"
        searchBar.searchBarStyle = .minimal
        searchBar.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        let item = UIBarButtonItem(customView: searchBar)
        return item
    }()
    // 아이템 추가 버튼
    private lazy var addItemButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: self,
        action: #selector(didTapAddItemButton)
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
        setupToolbarItems()
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
        navigationItem.rightBarButtonItems = [workspaceSettingButton, UIBarButtonItem(customView: queryOptionMenuButton)]
    }
    // Toolbar Item 설정
    func setupToolbarItems() {
        // 하단 툴바에 서치 바, 아이템 추가 버튼 추가
        bottomToolbar.setItems(
            [
                searchBarItem,
                UIBarButtonItem.flexibleSpace(),
                addItemButton
            ],
            animated: false
        )
        // 하위 뷰로 추가
        view.addSubview(bottomToolbar)
        // 제약 조건 설정
        bottomToolbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // Delegate 설정
    func setupDelegate() {
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
    }
    
    // ViewModel Output 바인딩
    func bindViewModel() {
        // Output 바인딩
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        // FilterMenuInfo 바인딩
        viewModel.onFilterMenuChanged = { [weak self] menuInfo in
            self?.updateFilterMenu(menuInfo)
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
            return
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
        // 특정 셀 삭제하기
        case .deleteRow(let index):
            let indexPath = IndexPath(row: index, section: 0)
            customView.tableView.performBatchUpdates {
                customView.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // Filter Menu 업데이트
    func updateFilterMenu(_ menuInfo: WorkspaceViewModel.FilterMenuInfo) {
        // 정렬 선택 메뉴 생성
        let sortMenu = makeSortMenu(menuInfo)
        // 카테고리 필터 선택 메뉴 생성
        let categoryMenu = makeCategoryFilterMenu(menuInfo)
        // 장소 필터 선택 메뉴 생성
        let locationMenu = makeLocationFilterMenu(menuInfo)
        // 아이템 상태 필터 선택 메뉴 생성
        let itemStateMenu = makeItemStateFilterMenu(menuInfo)
        // 뷰 프리셋 선택 메뉴 생성
        let presetMenu = makeViewPresetMenu(menuInfo)
        // 정렬, 필터 초기화 액션 생성
        let removeAction = makeRemoveFilterAction()
        
        // 정렬, 필터 적용 그룹
        let filterGroup = UIMenu(
            options: .displayInline,
            children: [sortMenu, categoryMenu, locationMenu, itemStateMenu, presetMenu]
        )
        
        // 정렬, 필터 초기화 그룹
        let removeGroup = UIMenu(
            options: .displayInline,
            children: [removeAction]
        )
        
        // 합쳐서 하나의 메뉴로 표시
        self.queryOptionMenuButton.menu = UIMenu(children: [filterGroup, removeGroup])
    }
    
    // 정렬 선택 메뉴 생성
    func makeSortMenu(_ menuInfo: WorkspaceViewModel.FilterMenuInfo) -> UIMenu {
        // 정렬 옵션 액션 생성
        var actionIcon: UIImage? = nil
        let sortOptions = menuInfo.sortOptions.map { option in
            switch option.sortingOptionCase {
            case .indexKey: actionIcon = Icons.quantity
            case .name: actionIcon = Icons.name
            case .nameDetail: actionIcon = Icons.nameDetail
            case .purchaseDate: actionIcon = Icons.purchaseDate
            case .purchasePlace: actionIcon = Icons.purchasePlace
            case .expireDate: actionIcon = Icons.expiration
            case .price: actionIcon = Icons.price
            case .quantity: actionIcon = Icons.quantity
            case .createdAt: actionIcon = Icons.created
            case .updatedAt: actionIcon = Icons.lastModified
            }
            return UIAction(
                title: option.toText(),
                image: actionIcon,
                state: option.sortingOptionCase == menuInfo.currentSortOption.sortingOptionCase ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectSortOption(option))
            }
        }
        // 오름차순 액션 생성
        let ascending = UIAction(
            title: menuInfo.currentSortOption.orderToText(isAscending: true),
            image: Icons.ascending,
            state: menuInfo.currentSortOption.order == .ascending ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.action(.selectSortOrder(.ascending))
        }
        // 내림차순 액션 생성
        let descending = UIAction(
            title: menuInfo.currentSortOption.orderToText(isAscending: false),
            image: Icons.descending,
            state: menuInfo.currentSortOption.order == .descending ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.action(.selectSortOrder(.descending))
        }
        // 정렬 옵션 그룹 생성
        let sortGroup = UIMenu(
            options: .displayInline,
            children: sortOptions
        )
        // 정렬 순서 그룹 생성
        let orderGroup = UIMenu(
            options: .displayInline,
            children: [ascending, descending]
        )
        // 정렬 선택 메뉴 생성
        let sortMenu = UIMenu(
            title: "Sort by",
            subtitle: menuInfo.currentSortOption.toText(),
            image: UIImage(systemName: "arrow.up.arrow.down"),
            children: [sortGroup, orderGroup]
        )
        
        return sortMenu
    }
    
    // 카테고리 필터 선택 메뉴 생성
    func makeCategoryFilterMenu(_ menuInfo: WorkspaceViewModel.FilterMenuInfo) -> UIMenu {
        // 액션 그룹 생성
        var categoryGroup: [UIAction] = []
        var removeGroup: [UIAction] = []
        // 현재 적용 중인 카테고리 표시를 위한 String
        var description: String? = nil
        // 워크스페이스에 카테고리가 없는 경우
        if menuInfo.categoryFilters.isEmpty {
            categoryGroup = [UIAction(
                title: "There's no category.",
                attributes: .disabled
            ) { _ in }]
        } else {
            categoryGroup = menuInfo.categoryFilters.map { category in
                // 현재 적용 중인 카테고리 문자열 교체
                if menuInfo.currentCategoryFilter?.uuid == category.id {
                    description = category.name
                }
                return UIAction(
                    title: category.name,
                    image: Icons.colorCircle?.withTintColor(category.color.toUIColor(), renderingMode: .alwaysOriginal),
                    state: menuInfo.currentCategoryFilter?.uuid == category.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectCategoryFilter(category))
                }
            }
            // 필터 제거 액션
            removeGroup = [UIAction(
                title: "Remove Category",
                image: UIImage(systemName: "trash")?.withTintColor(Colors.Theme.red.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
            ) { [weak self] _ in
                self?.viewModel.action(.selectCategoryFilter(nil))
            }]
        }
        // 선택 메뉴 생성
        let categoryMenu = UIMenu(
            options: .displayInline,
            children: categoryGroup
        )
        // 제거 메뉴 생성
        let removeMenu = UIMenu(
            options: .displayInline,
            children: removeGroup
        )
        // 메뉴 생성하여 반환
        return UIMenu(
            title: "Filter by Category",
            subtitle: description ?? "None",
            image: Icons.category,
            children: [categoryMenu, removeMenu]
        )
    }
    
    // 장소 필터 선택 메뉴 생성
    func makeLocationFilterMenu(_ menuInfo: WorkspaceViewModel.FilterMenuInfo) -> UIMenu {
        // 액션 그룹 생성
        var locationGroup: [UIAction] = []
        var removeGroup: [UIAction] = []
        // 현재 적용 중인 장소 표시를 위한 String
        var description: String? = nil
        // 워크스페이스에 장소가 없는 경우
        if menuInfo.locationFilters.isEmpty {
            locationGroup = [UIAction(
                title: "There's no location.",
                attributes: .disabled
            ) { _ in }]
        } else {
            locationGroup = menuInfo.locationFilters.map { location in
                // 현재 적용 중인 장소 문자열 교체
                if menuInfo.currentLocationFilter?.uuid == location.id {
                    description = location.name
                }
                return UIAction(
                    title: location.name,
                    image: Icons.colorCircle?.withTintColor(location.color.toUIColor(), renderingMode: .alwaysOriginal),
                    state: menuInfo.currentLocationFilter?.uuid == location.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectLocationFilter(location))
                }
            }
            // 필터 제거 액션
            removeGroup = [UIAction(
                title: "Remove Location",
                image: UIImage(systemName: "trash")?.withTintColor(Colors.Theme.red.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
            ) { [weak self] _ in
                self?.viewModel.action(.selectLocationFilter(nil))
            }]
        }
        // 선택 메뉴 생성
        let locationMenu = UIMenu(
            options: .displayInline,
            children: locationGroup
        )
        // 제거 메뉴 생성
        let removeMenu = UIMenu(
            options: .displayInline,
            children: removeGroup
        )
        // 메뉴 생성하여 반환
        return UIMenu(
            title: "Filter by Location",
            subtitle: description ?? "None",
            image: Icons.location,
            children: [locationMenu, removeMenu]
        )
    }
    
    // 아이템 상태 필터 선택 메뉴 생성
    func makeItemStateFilterMenu(_ menuInfo: WorkspaceViewModel.FilterMenuInfo) -> UIMenu {
        // 액션 그룹 생성
        var itemStateGroup: [UIAction] = []
        var removeGroup: [UIAction] = []
        // 현재 적용 중인 아이템 상태 표시를 위한 String
        var description: String? = nil
        // 워크스페이스에 아이템 상태가 없는 경우
        if menuInfo.itemStateFilters.isEmpty {
            itemStateGroup = [UIAction(
                title: "There's no Item State.",
                attributes: .disabled
            ) { _ in }]
        } else {
            itemStateGroup = menuInfo.itemStateFilters.map { itemState in
                // 현재 적용 중인 아이템 상태 문자열 교체
                if menuInfo.currentItemStateFilter?.uuid == itemState.id {
                    description = itemState.name
                }
                return UIAction(
                    title: itemState.name,
                    image: Icons.colorCircle?.withTintColor(itemState.color.toUIColor(), renderingMode: .alwaysOriginal),
                    state: menuInfo.currentItemStateFilter?.uuid == itemState.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectItemStateFilter(itemState))
                }
            }
            // 필터 제거 액션
            removeGroup = [UIAction(
                title: "Remove Item State",
                image: UIImage(systemName: "trash")?.withTintColor(Colors.Theme.red.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
            ) { [weak self] _ in
                self?.viewModel.action(.selectItemStateFilter(nil))
            }]
        }
        // 선택 메뉴 생성
        let itemStateMenu = UIMenu(
            options: .displayInline,
            children: itemStateGroup
        )
        // 제거 메뉴 생성
        let removeMenu = UIMenu(
            options: .displayInline,
            children: removeGroup
        )
        // 메뉴 생성하여 반환
        return UIMenu(
            title: "Filter by Item State",
            subtitle: description ?? "None",
            image: Icons.itemState,
            children: [itemStateMenu, removeMenu]
        )
    }
    
    // 뷰 프리셋 선택 메뉴 생성
    func makeViewPresetMenu(_ menuInfo: WorkspaceViewModel.FilterMenuInfo) -> UIMenu {
        // 액션 그룹 생성
        var viewPresetGroup: [UIAction] = []
        // 워크스페이스에 뷰 프리셋이 없는 경우
        if menuInfo.viewPresets.isEmpty {
            viewPresetGroup = [UIAction(
                title: "There's no Preset.",
                attributes: .disabled
            ) { _ in }]
        } else {
            viewPresetGroup = menuInfo.viewPresets.map { preset in
                return UIAction(
                    title: preset.name,
                ) { [weak self] _ in
                    self?.viewModel.action(.selectViewPreset(preset))
                }
            }
        }
        // 메뉴 생성하여 반환
        return UIMenu(
            title: "Apply Preset",
            image: Icons.viewPreset,
            children: viewPresetGroup
        )
    }
    
    // 정렬, 필터 초기화 액션 생성
    func makeRemoveFilterAction() -> UIAction {
        UIAction(
            title: "Remove Filters",
            image: UIImage(systemName: "trash")?.withTintColor(Colors.Theme.red.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
        ) { [weak self] _ in
            self?.viewModel.action(.selectRemoveFilters)
        }
    }
    
    // 워크스페이스 설정 버튼 선택 시 호출
    @objc func didTapSettingButton() {
        viewModel.action(.toWorkspaceSettings)
    }
    
    // 프리셋, 정렬, 필터 설정 메뉴 선택 시 호출
    @objc func didTapQueryOptionButton() {
        
    }
    
    // 아이템 추가 버튼 선택 시 호출
    @objc func didTapAddItemButton() {
        viewModel.action(.toAddItem)
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
        cell.onDeleteButtonTapped = { [weak self] in
            self?.viewModel.action(.tapDeleteButton(cellData))
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
