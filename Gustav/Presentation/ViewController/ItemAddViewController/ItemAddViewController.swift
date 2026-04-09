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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent {
            onRoute?(.dismiss)
        }
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

        // 오른쪽 버튼도 커스텀 checkmark가 아닌 시스템 기본 save 버튼을 사용합니다.
        let saveButton = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(didTapSave)
        )

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
        
        if output.isSaving {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        rootView.configureOptionValues(
            category: output.selectedCategoryName,
            itemState: output.selectedItemStateName,
            location: output.selectedLocationName
        )
        updateOptionMenus(output)
        
        rootView.purchaseDateCardView.setSwitchOn(output.isPurchaseDateEnabled, animated: false)
        rootView.expireDateCardView.setSwitchOn(output.isExpireDateEnabled, animated: false)
    }
    
    /// ViewModel의 라우팅 이벤트를 해석합니다.
    /// row 기준 dropdown popup은 ViewController가 직접 처리하고,
    /// 내비게이션성 이벤트만 Coordinator로 전달합니다.
    func handleRoute(_ route: ItemAddViewModel.Route) {
        switch route {
        case .dismiss, .dismissAfterSave, .showErrorAlert:
            onRoute?(route)
        }
    }
    
    func updateOptionMenus(_ output: ItemAddViewModel.Output) {
        rootView.categoryRowView.setMenuEnabled(true)
        rootView.categoryRowView.menu = makeCategoryMenu(output)
        
        rootView.itemStateRowView.setMenuEnabled(true)
        rootView.itemStateRowView.menu = makeItemStateMenu(output)
        
        rootView.locationRowView.setMenuEnabled(true)
        rootView.locationRowView.menu = makeLocationMenu(output)
    }
    
    func makeCategoryMenu(_ output: ItemAddViewModel.Output) -> UIMenu {
        var actions = output.availableCategories
            .sorted { $0.indexKey < $1.indexKey }
            .map { category in
                UIAction(
                    title: category.name,
                    state: output.selectedCategoryID == category.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectCategory(id: category.id, name: category.name))
                }
            }
        
        if actions.isEmpty {
            actions = [UIAction(title: "There's no category.", attributes: .disabled) { _ in }]
        }
        
        let clearAction = UIAction(
            title: "Clear Category",
            attributes: output.selectedCategoryID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectCategory(id: nil, name: nil))
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
    
    func makeItemStateMenu(_ output: ItemAddViewModel.Output) -> UIMenu {
        var actions = output.availableItemStates
            .sorted { $0.indexKey < $1.indexKey }
            .map { itemState in
                UIAction(
                    title: itemState.name,
                    state: output.selectedItemStateID == itemState.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectItemState(id: itemState.id, name: itemState.name))
                }
            }
        
        if actions.isEmpty {
            actions = [UIAction(title: "There's no Item State.", attributes: .disabled) { _ in }]
        }
        
        let clearAction = UIAction(
            title: "Clear Item State",
            attributes: output.selectedItemStateID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectItemState(id: nil, name: nil))
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
    
    func makeLocationMenu(_ output: ItemAddViewModel.Output) -> UIMenu {
        var actions = output.availableLocations
            .sorted { $0.indexKey < $1.indexKey }
            .map { location in
                UIAction(
                    title: location.name,
                    state: output.selectedLocationID == location.id ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.action(.selectLocation(id: location.id, name: location.name))
                }
            }
        
        if actions.isEmpty {
            actions = [UIAction(title: "There's no location.", attributes: .disabled) { _ in }]
        }
        
        let clearAction = UIAction(
            title: "Clear Location",
            attributes: output.selectedLocationID == nil ? [.disabled] : [.destructive]
        ) { [weak self] _ in
            self?.viewModel.action(.selectLocation(id: nil, name: nil))
        }
        
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: actions),
            UIMenu(options: .displayInline, children: [clearAction])
        ])
    }
}

// MARK: - Navigation Bar Actions

private extension ItemAddViewController {
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
 
