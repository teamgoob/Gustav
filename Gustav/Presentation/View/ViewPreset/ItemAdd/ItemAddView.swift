//
//  ItemAddView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit
import SnapKit
import SwiftUI

final class ItemAddView: UIView {

    // MARK: - UI

    // 스크롤 가능한 전체 컨테이너
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()

    // 물품 기본 정보 입력 카드
    let itemNameCardView = ItemAddTextFieldCardView(
        style: .double,
        firstPlaceholder: "Item name",
        secondPlaceholder: "detail name"
    )

    let priceQuantityCardView = ItemAddTextFieldCardView(
        style: .double,
        firstPlaceholder: "price",
        secondPlaceholder: "quantity"
    )

    // 메모 입력 카드
    let memoCardView = ItemMemoCardView()

    let purchasePlaceCardView = ItemAddTextFieldCardView(
        style: .single,
        firstPlaceholder: "Purchased place"
    )

    // 날짜 정보 입력 카드
    let purchaseDateCardView = ItemAddDateCardView(
        configuration: .init(
            toggleTitle: "Purchase Date",
            dateTitle: "Date",
            dateText: "",
            timeText: "",
            isOn: true
        )
    )

    let expireDateCardView = ItemAddDateCardView(
        configuration: .init(
            toggleTitle: "Purchase Expire at",
            dateTitle: "Date",
            dateText: "",
            timeText: "",
            isOn: true
        )
    )

    // 선택형 옵션 영역
    private let optionSectionStackView = UIStackView()
    let categoryRowView = OptionRowView()
    let itemStateRowView = OptionRowView()
    let locationRowView = OptionRowView()

    // MARK: - Callback

    // 카테고리 행 탭 이벤트를 외부로 전달합니다.
    var onTapCategory: (() -> Void)?

    // 물품 상태 행 탭 이벤트를 외부로 전달합니다.
    var onTapItemState: (() -> Void)?

    // 위치 행 탭 이벤트를 외부로 전달합니다.
    var onTapLocation: (() -> Void)?

    // MARK: - Init

    // 뷰 초기 생성 시 UI, 레이아웃, 기본값을 순서대로 설정합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        configureDefaultValues()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    // 선택형 옵션 행의 표시 값을 외부에서 업데이트합니다.
    func configureOptionValues(
        category: String?,
        itemState: String?,
        location: String?
    ) {
        categoryRowView.configure(title: "Category", value: category ?? "none")
        itemStateRowView.configure(title: "Item state", value: itemState ?? "none")
        locationRowView.configure(title: "Location", value: location ?? "none")
    }

    // MARK: - Setup

    // 뷰 계층 구성과 기본 스타일, 초기 설정을 담당합니다.
    private func setupUI() {
        // 화면 전체 배경색 설정
        backgroundColor = Colors.Theme.mainBackground

        // 스택뷰, 입력 방식, placeholder, 탭 액션 등 초기 UI 설정
        setupMainStackView()
        setupOptionSectionStackView()
        setupInputKeyboardTypes()
        setupMemoPlaceholder()
        setupOptionRowActions()

        // 스크롤 구조 구성
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)

        // 메인 스택뷰에 각 입력 카드와 옵션 영역 추가
        mainStackView.addArrangedSubview(itemNameCardView)
        mainStackView.addArrangedSubview(priceQuantityCardView)
        mainStackView.addArrangedSubview(memoCardView)
        mainStackView.addArrangedSubview(purchasePlaceCardView)
        mainStackView.addArrangedSubview(purchaseDateCardView)
        mainStackView.addArrangedSubview(expireDateCardView)
        mainStackView.addArrangedSubview(optionSectionStackView)

        // 옵션 영역 내부에 선택 행 추가
        optionSectionStackView.addArrangedSubview(categoryRowView)
        optionSectionStackView.addArrangedSubview(itemStateRowView)
        optionSectionStackView.addArrangedSubview(locationRowView)
    }

    // 전체 입력 카드들을 세로로 배치할 메인 스택뷰를 설정합니다.
    private func setupMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
    }

    // 카테고리, 상태, 위치 행을 담을 옵션 스택뷰를 설정합니다.
    private func setupOptionSectionStackView() {
        optionSectionStackView.axis = .vertical
        optionSectionStackView.spacing = 12
        optionSectionStackView.alignment = .fill
        optionSectionStackView.distribution = .fill
    }

    // 숫자 입력이 필요한 필드에 숫자 키보드를 적용합니다.
    private func setupInputKeyboardTypes() {
        priceQuantityCardView.setFirstKeyboardType(.numberPad)
        priceQuantityCardView.setSecondKeyboardType(.numberPad)
    }

    // 메모 입력 카드의 placeholder를 설정합니다.
    private func setupMemoPlaceholder() {
        memoCardView.setPlaceholder("memo")
    }

    // 선택형 옵션 행의 탭 액션을 연결합니다.
    private func setupOptionRowActions() {
        categoryRowView.addTarget(self, action: #selector(didTapCategoryRow), for: .touchUpInside)
        itemStateRowView.addTarget(self, action: #selector(didTapItemStateRow), for: .touchUpInside)
        locationRowView.addTarget(self, action: #selector(didTapLocationRow), for: .touchUpInside)
    }

    // 옵션 행의 초기 표시값을 기본 상태로 설정합니다.
    private func configureDefaultValues() {
        configureOptionValues(category: nil, itemState: nil, location: nil)
    }

    // MARK: - Actions

    // 카테고리 행이 탭되면 외부 콜백을 실행합니다.
    @objc private func didTapCategoryRow() {
        onTapCategory?()
    }

    // 물품 상태 행이 탭되면 외부 콜백을 실행합니다.
    @objc private func didTapItemStateRow() {
        onTapItemState?()
    }

    // 위치 행이 탭되면 외부 콜백을 실행합니다.
    @objc private func didTapLocationRow() {
        onTapLocation?()
    }

    // MARK: - Layout

    // 스크롤 구조와 각 입력 카드의 크기 및 간격을 설정합니다.
    private func setupLayout() {
        // 스크롤뷰가 안전 영역을 기준으로 화면 전체를 채우도록 설정
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()        }

        // contentView가 scrollView의 콘텐츠 영역을 모두 채우고,
        // 가로 폭은 스크롤뷰와 동일하게 유지되도록 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // 메인 스택뷰를 contentView 내부에 배치하고 좌우/하단 여백 적용
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }

        // 메모 입력 카드는 최소 높이를 보장
        memoCardView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(104)
        }

        // 날짜 카드의 고정 높이 설정
        purchaseDateCardView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }

        expireDateCardView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }

        // 옵션 행들의 높이를 동일하게 맞춤
        [categoryRowView, itemStateRowView, locationRowView].forEach { row in
            row.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }

}

// MARK: - Preview
#if DEBUG
private struct ItemAddViewPreview: UIViewRepresentable {
    let category: String?
    let itemState: String?
    let location: String?

    func makeUIView(context: Context) -> UIView {
        let view = ItemAddView()
        view.configureOptionValues(
            category: category,
            itemState: itemState,
            location: location
        )
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

@available(iOS 17.0, *)
#Preview("ItemAddView - Default") {
    ItemAddViewPreview(
        category: nil,
        itemState: nil,
        location: nil
    )
}

@available(iOS 17.0, *)
#Preview("ItemAddView - Category Selected") {
    ItemAddViewPreview(
        category: "Electronics",
        itemState: nil,
        location: nil
    )
}
#endif
