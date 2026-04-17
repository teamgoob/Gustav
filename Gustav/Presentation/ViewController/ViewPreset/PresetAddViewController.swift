//
//  PresetAddViewController.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit

// 프리셋 추가 화면의 UI 바인딩과 사용자 이벤트 전달을 담당하는 ViewController
final class PresetAddViewController: UIViewController {
    
    // MARK: - Callback
    var onBack: (() -> Void)?
    var onSaveSuccess: (() -> Void)?
    
    // MARK: - Properties
    // 화면 루트 뷰와 ViewModel
    private let contentView = PresetAddView()
    // 화면 상태와 액션을 담당하는 ViewModel
    private let viewModel: PresetAddViewModel
    // 저장 버튼
    private lazy var saveButton = UIBarButtonItem(
        image: UIImage(systemName: "checkmark"),
        style: .done,
        target: self,
        action: #selector(didTapSaveButton)
    )
    
    // MARK: - Init
    init(viewModel: PresetAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    // 커스텀 루트 뷰 연결
    override func loadView() {
        view = contentView
    }
    
    // 네비게이션, 바인딩, 초기 액션 연결
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupGesture()
        bindViewModel()
        bindActions()
        viewModel.action(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // navigationBar 전체 높이 재계산, push 애니메이션 중 inline 형태로 보이는 현상을 줄임
        navigationController?.navigationBar.sizeToFit()
    }
}

// MARK: - Setup
private extension PresetAddViewController {
    // 네비게이션 바 기본 구성
    func setupNavigationBar() {
        title = "Add Preset"
        navigationItem.largeTitleDisplayMode = .always
        // Subtitle 공간 계산을 위해 임시 값으로 Large Subtitle 영역 확보
        applySubtitle("Workspace Name")
        navigationItem.rightBarButtonItem = saveButton
    }

    // large / compact 상태에 공통으로 표시할 워크스페이스 subtitle 적용
    func applySubtitle(_ text: String) {
        var largeSubtitle = AttributedString(text)
        largeSubtitle.font = Fonts.accent
        largeSubtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = largeSubtitle

        var compactSubtitle = AttributedString(text)
        compactSubtitle.font = Fonts.additional
        compactSubtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.attributedSubtitle = compactSubtitle
    }
    
    // ViewModel 출력값과 라우팅 이벤트를 UI에 연결
    func bindViewModel() {
        // 화면 표시 데이터 반영
        viewModel.onDisplay = { [weak self] output in
            guard let self else { return }
            self.applySubtitle(output.workspaceName)
            
            self.contentView.configure(
                name: output.name,
                viewType: output.viewType,
                sortingOption: output.sortingOption,
                sortingOrder: output.sortingOrder,
                category: output.category,
                subcategory: output.subcategory,
                showsSubcategory: output.showsSubcategory,
                location: output.location,
                itemStatus: output.itemStatus
            )
            
            self.saveButton.isEnabled = output.isSaveEnabled
            self.navigationItem.rightBarButtonItem?.isEnabled = output.isSaveEnabled
        }
        
        // 필터 메뉴 구성 변경 반영
        viewModel.onFilterMenuChanged = { [weak self] menuInfo in
            self?.updateFilterMenu(menuInfo)
        }
        
        // 화면 이동 및 알럿 이벤트 처리
        viewModel.onNavigation = { [weak self] route in
            guard let self else { return }
            
            switch route {
            case .pop:
                self.onBack?()

            case .showLoadFailureAlert(let message):
                self.presentAlert(message: message)
                
            case .showValidationAlert(let message):
                self.presentAlert(message: message)
                
            case .showSaveFailureAlert(let message):
                self.presentAlert(message: message)
                
            case .showSaveSuccess:
                self.onSaveSuccess?()
            }
        }
    }
    
    // View의 사용자 입력 콜백 연결
    func bindActions() {
        bindNameInput()
    }
    
    // 이름 입력 변경을 ViewModel 액션으로 전달
    func bindNameInput() {
        contentView.nameCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.didChangeName(text))
        }
    }
    
    // 현재 메뉴 상태를 각 행의 UIMenu와 표시 상태에 반영
    func updateFilterMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) {
        contentView.viewTypeRow.setMenuEnabled(true)
        contentView.viewTypeRow.menu = makeViewTypeMenu(menuInfo)

        contentView.sortByRow.setMenuEnabled(true)
        contentView.sortByRow.menu = makeSortByMenu(menuInfo)

        contentView.sortOrderRow.setMenuEnabled(true)
        contentView.sortOrderRow.menu = makeSortOrderMenu(menuInfo)

        contentView.categoryRow.setMenuEnabled(true)
        contentView.categoryRow.menu = makeCategoryMenu(menuInfo)

        contentView.subcategoryRow.isHidden = menuInfo.childCategoryFilters.isEmpty
        contentView.subcategoryRow.setMenuEnabled(menuInfo.childCategoryFilters.isEmpty == false)
        contentView.subcategoryRow.menu = menuInfo.childCategoryFilters.isEmpty ? nil : makeSubcategoryMenu(menuInfo)

        contentView.locationRow.setMenuEnabled(true)
        contentView.locationRow.menu = makeLocationMenu(menuInfo)

        contentView.itemStatusRow.setMenuEnabled(true)
        contentView.itemStatusRow.menu = makeItemStatusMenu(menuInfo)
    }
    
    // 상위 카테고리 선택 메뉴 생성
    func makeCategoryMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.parentCategoryFilters.map { option in
            UIAction(
                title: option.title,
                image: Icons.tagColorCircle(option.color),
                state: menuInfo.currentParentCategoryID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectParentCategoryFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no category.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Category",
            attributes: menuInfo.currentParentCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.clearCategorySelection()
        }

        let categoryGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [categoryGroup, clearGroup])
    }

    // 하위 카테고리 선택 메뉴 생성
    func makeSubcategoryMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.childCategoryFilters.map { option in
            UIAction(
                title: option.title,
                image: Icons.tagColorCircle(option.color),
                state: menuInfo.currentChildCategoryID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectChildCategoryFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no subcategory.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Subcategory",
            attributes: menuInfo.currentChildCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectChildCategoryFilter(nil))
        }

        let categoryGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [categoryGroup, clearGroup])
    }

    // 위치 선택 메뉴 생성
    func makeLocationMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.locationFilters.map { option in
            UIAction(
                title: option.title,
                image: Icons.tagColorCircle(option.color),
                state: menuInfo.currentLocationID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectLocationFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no location.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Location",
            attributes: menuInfo.currentLocationID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.clearLocationSelection()
        }

        let locationGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [locationGroup, clearGroup])
    }

    // 아이템 상태 선택 메뉴 생성
    func makeItemStatusMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        var actions = menuInfo.itemStateFilters.map { option in
            UIAction(
                title: option.title,
                image: Icons.tagColorCircle(option.color),
                state: menuInfo.currentItemStateID == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectItemStateFilter(option.id))
            }
        }

        if actions.isEmpty {
            actions = [
                UIAction(
                    title: "There's no Item State.",
                    attributes: .disabled
                ) { _ in }
            ]
        }

        let clearAction = UIAction(
            title: "Clear Item State",
            attributes: menuInfo.currentItemStateID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.clearItemStatusSelection()
        }

        let itemStateGroup = UIMenu(options: .displayInline, children: actions)
        let clearGroup = UIMenu(options: .displayInline, children: [clearAction])
        return UIMenu(children: [itemStateGroup, clearGroup])
    }

    // 상위 카테고리 선택 해제
    func clearCategorySelection() {
        viewModel.action(.selectParentCategoryFilter(nil))
    }

    // 위치 선택 해제
    func clearLocationSelection() {
        viewModel.action(.selectLocationFilter(nil))
    }

    // 아이템 상태 선택 해제
    func clearItemStatusSelection() {
        viewModel.action(.selectItemStateFilter(nil))
    }
}

// MARK: - Action
private extension PresetAddViewController {
    // 프리셋 뷰 타입 선택 메뉴 생성
    func makeViewTypeMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        let actions = menuInfo.viewTypeOptions.map { option in
            UIAction(
                title: option.title,
                state: menuInfo.currentViewType == option.id ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectViewType(option.id))
            }
        }

        return UIMenu(children: actions)
    }

    // 정렬 기준 선택 메뉴 생성
    func makeSortByMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        let isDefaultSort: Bool
        if case .updatedAt(order: .descending)? = menuInfo.currentSortOption {
            isDefaultSort = true
        } else {
            isDefaultSort = false
        }

        let actions = menuInfo.sortOptions.map { option in
            UIAction(
                title: option.toText(),
                state: option.sortingOptionCase == menuInfo.currentSortOption?.sortingOptionCase ? .on : .off
            ) { [weak self] _ in
                self?.viewModel.action(.selectSortOption(option))
            }
        }

        let clearAction = UIAction(
            title: "Clear Sort By",
            attributes: isDefaultSort ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.clearSortOption)
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }

    // 정렬 순서 선택 메뉴 생성

    func makeSortOrderMenu(_ menuInfo: PresetAddViewModel.FilterMenuInfo) -> UIMenu {
        let isDefaultSort: Bool
        
        if case .updatedAt(order: .descending)? = menuInfo.currentSortOption {
            isDefaultSort = true
        } else {
            isDefaultSort = false
        }

        let referenceSortOption = menuInfo.currentSortOption ?? .updatedAt(order: .descending)

        let ascending = UIAction(
            title: referenceSortOption.orderToText(isAscending: true),
            state: menuInfo.currentSortOption?.order == .ascending ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.action(.selectSortOrder(.ascending))
        }

        let descending = UIAction(
            title: referenceSortOption.orderToText(isAscending: false),
            state: menuInfo.currentSortOption?.order == .descending ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.action(.selectSortOrder(.descending))
        }

        let clearAction = UIAction(
            title: "Clear Sort Order",
            attributes: isDefaultSort ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.clearSortOrder)
        }

        return UIMenu(children: [
            UIMenu(options: .displayInline, children: [ascending, descending]),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
    
    // 키보드 내리기
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 뒤로 가기 버튼 탭 처리
    @objc func didTapBackButton() {
        viewModel.action(.didTapBack)
    }
    
    // 저장 버튼 탭 처리
    @objc func didTapSaveButton() {
        viewModel.action(.didTapSave)
    }
}

// MARK: - Alert
private extension PresetAddViewController {
    // 단순 메시지 알럿 표시
    func presentAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
