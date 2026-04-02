//
//  ItemAddViewController.swift.swift
//  Gustav
//
//  Created by kaeun on 4/1/26.
//
import UIKit
import SnapKit

/// 아이템 생성 화면을 담당하는 ViewController
/// 역할: View ↔ ViewModel 바인딩 및 Navigation 이벤트 전달
final class ItemAddViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 화면 UI를 담당하는 커스텀 View
    private let rootView = ItemAddView()
    /// 비즈니스 로직 및 상태를 관리하는 ViewModel
    private let viewModel: ItemAddViewModel
    
    /// row 기준 custom dropdown 표시를 담당하는 재사용 가능한 UI 헬퍼 객체
    private lazy var dropdownManager = DropdownOverlayManager(hostViewController: self)

    /// dropdown popup에 표시할 카테고리 목록
    private var categories: [Category] = []

    /// dropdown popup에 표시할 아이템 상태 목록
    private var itemStates: [ItemState] = []

    /// dropdown popup에 표시할 위치 목록
    private var locations: [Location] = []

    /// 현재 선택된 카테고리 ID
    private var selectedCategoryID: UUID?

    /// 현재 선택된 아이템 상태 ID
    private var selectedItemStateID: UUID?

    /// 현재 선택된 위치 ID
    private var selectedLocationID: UUID?
    
    /// Coordinator로 화면 전환 이벤트를 전달하기 위한 클로저
    /// dismiss / dismissAfterSave / showErrorAlert 같은 내비게이션성 이벤트만 전달합니다.
    var onRoute: ((ItemAddViewModel.Route) -> Void)?
    
    // MARK: - Init
    
    init(viewModel: ItemAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupNavigation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// dropdown popup에 사용할 도메인 모델 목록을 주입합니다.
    func configureDropdownData(
        categories: [Category],
        itemStates: [ItemState],
        locations: [Location]
    ) {
        self.categories = categories.sorted { $0.indexKey < $1.indexKey }
        self.itemStates = itemStates.sorted { $0.indexKey < $1.indexKey }
        self.locations = locations.sorted { $0.indexKey < $1.indexKey }
    }
    
    // MARK: - Life Cycle
    
    /// UIViewController의 rootView를 커스텀 뷰로 교체
    override func loadView() {
        view = rootView
    }
    
    /// 초기 설정 및 바인딩 수행
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupNavigation()
        setupGesture()
        bindViewModel()
        bindActions()
        bindInputs()
        viewModel.action(.viewDidLoad)
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

// MARK: - Navigation

private extension ItemAddViewController {
    /// 네비게이션 바 구성 (닫기 / 저장 버튼)
    func setupNavigation() {
        navigationItem.title = "Add Item"
        navigationItem.largeTitleDisplayMode = .always
       
        var subtitle = AttributedString("")
        // Large Title 하단에 표시되는 Large Subtitle 텍스트 설정
        subtitle.font = Fonts.accent
        subtitle.foregroundColor = Colors.Text.additionalInfo
        navigationItem.largeAttributedSubtitle = subtitle
        // 스크롤 시 상단 Title 하단에 표시되는 Subtitle 텍스트 설정
        subtitle.font = Fonts.additional
        navigationItem.attributedSubtitle = subtitle

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        
        let saveButton: UIBarButtonItem

        if #available(iOS 26.0, *) {
            saveButton = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .prominent,
                target: self,
                action: #selector(didTapSave)
            )
        } else {
            saveButton = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .done,
                target: self,
                action: #selector(didTapSave)
            )
        }

        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton

    }

}


// MARK: - Bind ViewModel

private extension ItemAddViewController {
    /// ViewModel → View 데이터 바인딩
    func bindViewModel() {
        viewModel.onDisplay = { [weak self] output in
            self?.apply(output)
        }
        
        viewModel.onNavigation = { [weak self] route in
            self?.handleRoute(route)
        }
    }
}

// MARK: - Bind View Actions

private extension ItemAddViewController {
    /// View 내부 탭 이벤트 → ViewModel 전달
    func bindActions() {
        rootView.onTapCategory = { [weak self] in
            self?.viewModel.action(.tapCategory)
        }
        
        rootView.onTapItemState = { [weak self] in
            self?.viewModel.action(.tapItemState)
        }
        
        rootView.onTapLocation = { [weak self] in
            self?.viewModel.action(.tapLocation)
        }
    }
}

// MARK: - Bind Input Components

private extension ItemAddViewController {
    /// 사용자 입력값 → ViewModel 전달
    func bindInputs() {
        bindNameInput()
        bindPriceQuantityInput()
        bindPurchasePlaceInput()
        bindMemoInput()
        bindPurchaseDateInput()
        bindExpireDateInput()
    }

    /// 이름 입력 바인딩
    func bindNameInput() {
        rootView.itemNameCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.changeName(text))
        }
        
        rootView.itemNameCardView.onSecondTextChanged = { [weak self] text in
            self?.viewModel.action(.changeDetailName(text))
        }
    }
    
    /// 가격/수량 입력 바인딩
    func bindPriceQuantityInput() {
        rootView.priceQuantityCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.changePrice(text))
        }
        
        rootView.priceQuantityCardView.onSecondTextChanged = { [weak self] text in
            self?.viewModel.action(.changeQuantity(text))
        }
    }
    
    /// 구매처 입력 바인딩
    func bindPurchasePlaceInput() {
        rootView.purchasePlaceCardView.onFirstTextChanged = { [weak self] text in
            self?.viewModel.action(.changePurchasePlace(text))
        }
    }
    
    /// 메모 입력 바인딩
    func bindMemoInput() {
        rootView.memoCardView.onTextChanged = { [weak self] text in
            self?.viewModel.action(.changeMemo(text))
        }
    }
    
    /// 구매일 입력 바인딩
    func bindPurchaseDateInput() {
        rootView.purchaseDateCardView.onSwitchChanged = { [weak self] isOn in
            self?.viewModel.action(.togglePurchaseDate(isOn))
        }
        
        rootView.purchaseDateCardView.onDateChanged = { [weak self] date in
            self?.viewModel.action(.changePurchaseDate(date))
        }
        
        rootView.purchaseDateCardView.onTimeChanged = { [weak self] time in
            self?.viewModel.action(.changePurchaseTime(time))
        }
    }
    
    /// 만료일 입력 바인딩
    func bindExpireDateInput() {
        rootView.expireDateCardView.onSwitchChanged = { [weak self] isOn in
            self?.viewModel.action(.toggleExpireDate(isOn))
        }
        
        rootView.expireDateCardView.onDateChanged = { [weak self] date in
            self?.viewModel.action(.changeExpireDate(date))
        }
        
        rootView.expireDateCardView.onTimeChanged = { [weak self] time in
            self?.viewModel.action(.changeExpireTime(time))
        }
    }
}

// MARK: - Apply Output / Route

private extension ItemAddViewController {
    /// ViewModel Output을 UI에 반영
    func apply(_ output: ItemAddViewModel.Output) {
        navigationItem.rightBarButtonItem?.isEnabled = output.saveButtonEnabled
        navigationItem.leftBarButtonItem?.isEnabled = !output.isSaving
        
        if output.isSaving {
            navigationItem.rightBarButtonItem?.title = "Saving..."
        } else {
            navigationItem.rightBarButtonItem?.title = "Save"
        }
        
        rootView.configureOptionValues(
            category: output.selectedCategoryName,
            itemState: output.selectedItemStateName,
            location: output.selectedLocationName
        )

        if let selectedCategoryName = output.selectedCategoryName {
            selectedCategoryID = categories.first(where: { $0.name == selectedCategoryName })?.id
        } else {
            selectedCategoryID = nil
        }
        
        if let selectedItemStateName = output.selectedItemStateName {
            selectedItemStateID = itemStates.first(where: { $0.name == selectedItemStateName })?.id
        } else {
            selectedItemStateID = nil
        }
        
        if let selectedLocationName = output.selectedLocationName {
            selectedLocationID = locations.first(where: { $0.name == selectedLocationName })?.id
        } else {
            selectedLocationID = nil
        }
        
        rootView.purchaseDateCardView.setSwitchOn(output.isPurchaseDateEnabled, animated: false)
        rootView.expireDateCardView.setSwitchOn(output.isExpireDateEnabled, animated: false)
    }
    
    /// ViewModel의 라우팅 이벤트를 해석합니다.
    /// row 기준 dropdown popup은 ViewController가 직접 처리하고,
    /// 내비게이션성 이벤트만 Coordinator로 전달합니다.
    func handleRoute(_ route: ItemAddViewModel.Route) {
        switch route {
        case .showCategoryPicker:
            showCategoryDropdown(from: rootView.categoryRowView)
            
        case .showItemStatePicker:
            showItemStateDropdown(from: rootView.itemStateRowView)
            
        case .showLocationPicker:
            showLocationDropdown(from: rootView.locationRowView)
            
        case .dismiss, .dismissAfterSave, .showErrorAlert:
            dropdownManager.dismiss(animated: false)
            onRoute?(route)
        }
    }

    /// category row를 anchor로 삼아 dropdown popup을 표시합니다.
    func showCategoryDropdown(from anchorView: UIView) {
        let popupView = makeCategoryDropdownView()
        dropdownManager.present(
            contentView: popupView,
            from: anchorView,
            preferredSize: preferredDropdownSize(for: anchorView, itemCount: max(categories.count, 1))
        )
    }

    /// item state row를 anchor로 삼아 dropdown popup을 표시합니다.
    func showItemStateDropdown(from anchorView: UIView) {
        let popupView = makeItemStateDropdownView()
        dropdownManager.present(
            contentView: popupView,
            from: anchorView,
            preferredSize: preferredDropdownSize(for: anchorView, itemCount: max(itemStates.count, 1))
        )
    }

    /// location row를 anchor로 삼아 dropdown popup을 표시합니다.
    func showLocationDropdown(from anchorView: UIView) {
        let popupView = makeLocationDropdownView()
        dropdownManager.present(
            contentView: popupView,
            from: anchorView,
            preferredSize: preferredDropdownSize(for: anchorView, itemCount: max(locations.count, 1))
        )
    }

    /// anchor row의 폭과 옵션 개수를 기준으로 dropdown popup의 기본 크기를 계산합니다.
    func preferredDropdownSize(for anchorView: UIView, itemCount: Int) -> CGSize {
        let rowHeight: CGFloat = 44
        let verticalPadding: CGFloat = 16
        let maxVisibleRows = min(itemCount, 5)
        let height = CGFloat(maxVisibleRows) * rowHeight + verticalPadding
        return CGSize(width: anchorView.bounds.width, height: height)
    }
    
    /// category 도메인 모델을 OptionPopupItem으로 매핑하여 dropdown view를 생성합니다.
    func makeCategoryDropdownView() -> UIView {
        let items = categories.map {
            OptionPopupItem(id: $0.id.uuidString, title: $0.name)
        }
        
        let popupView = OptionPopupView(
            items: items,
            selectedItemID: selectedCategoryID?.uuidString
        )
        
        popupView.onSelectItem = { [weak self] selectedItem in
            guard let self else { return }
            self.dropdownManager.dismiss(animated: true)
            
            guard
                let selectedCategory = self.categories.first(where: {
                    $0.id.uuidString == selectedItem.id
                })
            else {
                return
            }
            
            self.selectedCategoryID = selectedCategory.id
            self.viewModel.action(
                .selectCategory(id: selectedCategory.id, name: selectedCategory.name)
            )
        }
        
        return popupView
    }

    /// item state 도메인 모델을 OptionPopupItem으로 매핑하여 dropdown view를 생성합니다.
    func makeItemStateDropdownView() -> UIView {
        let items = itemStates.map {
            OptionPopupItem(id: $0.id.uuidString, title: $0.name)
        }
        
        let popupView = OptionPopupView(
            items: items,
            selectedItemID: selectedItemStateID?.uuidString
        )
        
        popupView.onSelectItem = { [weak self] selectedItem in
            guard let self else { return }
            self.dropdownManager.dismiss(animated: true)
            
            guard
                let selectedState = self.itemStates.first(where: {
                    $0.id.uuidString == selectedItem.id
                })
            else {
                return
            }
            
            self.selectedItemStateID = selectedState.id
            self.viewModel.action(
                .selectItemState(id: selectedState.id, name: selectedState.name)
            )
        }
        
        return popupView
    }

    /// location 도메인 모델을 OptionPopupItem으로 매핑하여 dropdown view를 생성합니다.
    func makeLocationDropdownView() -> UIView {
        let items = locations.map {
            OptionPopupItem(id: $0.id.uuidString, title: $0.name)
        }
        
        let popupView = OptionPopupView(
            items: items,
            selectedItemID: selectedLocationID?.uuidString
        )
        
        popupView.onSelectItem = { [weak self] selectedItem in
            guard let self else { return }
            self.dropdownManager.dismiss(animated: true)
            
            guard
                let selectedLocation = self.locations.first(where: {
                    $0.id.uuidString == selectedItem.id
                })
            else {
                return
            }
            
            self.selectedLocationID = selectedLocation.id
            self.viewModel.action(
                .selectLocation(id: selectedLocation.id, name: selectedLocation.name)
            )
        }
        
        return popupView
    }
}

// MARK: - Navigation Bar Actions

private extension ItemAddViewController {
    /// overlay 영역 탭 시 dropdown popup을 닫습니다.
    @objc func didTapDropdownOverlay() {
        dropdownManager.dismiss(animated: true)
    }
    
    /// 닫기 버튼 탭 → ViewModel 전달
    @objc func didTapClose() {
        viewModel.action(.dismiss)
    }
    
    /// 저장 버튼 탭 → ViewModel 전달
    @objc func didTapSave() {
        viewModel.action(.tapSave)
    }
}

// MARK: - Gesture / Keyboard

private extension ItemAddViewController {
    /// 빈 화면을 탭하면 키보드를 내립니다.
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    /// 현재 포커스된 입력 뷰를 종료하여 키보드를 내립니다.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
 
