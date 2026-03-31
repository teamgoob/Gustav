//
//  OptionPopupView.swift
//  Gustav
//
//  Created by kaeun on 3/30/26.
//

import UIKit
import SnapKit

// MARK: - Model
// OptionPopupView에서 사용하는 데이터 모델
// id: 선택 상태 비교 및 식별용
// title: UI에 표시되는 문자열

// 팝업 리스트의 각 항목을 표현하는 모델
struct OptionPopupItem: Hashable {
    // 고유 식별자 (선택 상태 판단용)
    let id: String
    // 화면에 표시할 텍스트
    let title: String

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    init(title: String) {
        self.id = title
        self.title = title
    }
}

// 선택 가능한 리스트를 카드 형태로 보여주는 커스텀 팝업 뷰
// - UIView 기반으로 구성
// - 외부(ViewController)에서 show/hide 및 위치 제어
// - 내부에서는 리스트 렌더링과 선택 이벤트만 담당
final class OptionPopupView: UIView {

    // 선택된 항목을 외부로 전달하는 콜백
    // MARK: - Callback
    var onSelectItem: ((OptionPopupItem) -> Void)?

    // containerView: 카드 UI (둥근 모서리 + shadow)
    // stackView: 옵션 리스트를 세로로 나열
    // MARK: - UI
    private let containerView = UIView()
    private let stackView = UIStackView()

    // items: 현재 표시할 옵션 목록
    // selectedItemID: 현재 선택된 항목의 id
    // MARK: - Properties
    private var items: [OptionPopupItem] = []
    private var selectedItemID: String?

    // 기본 초기화
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 외부에서 데이터 주입
    // MARK: - Public
    func configure(items: [OptionPopupItem], selectedItemID: String?) {
        self.items = items
        self.selectedItemID = selectedItemID
        // 데이터 갱신 후 UI 다시 구성
        reloadOptions()
    }

    func configure(titles: [String], selectedTitle: String?) {
        // 단순 String 배열을 OptionPopupItem으로 변환하는 편의 메서드
        let popupItems = titles.map { OptionPopupItem(title: $0) }
        configure(items: popupItems, selectedItemID: selectedTitle)
    }

    // UI 요소 생성 및 스타일 설정
    // MARK: - Setup
    private func setupUI() {
        // 배경은 투명 (오버레이 위에 올라가는 구조)
        backgroundColor = .clear

        // 카드 스타일 (cornerRadius + border + shadow)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 28
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.04).cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.12
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.masksToBounds = false

        // 옵션을 세로로 나열하기 위한 스택뷰
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0

        addSubview(containerView)
        containerView.addSubview(stackView)
    }

    // 레이아웃 설정 (SnapKit 사용)
    private func setupLayout() {
        // containerView는 전체 영역을 차지
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // stackView는 containerView 내부에 꽉 차도록 배치
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // 현재 items 기반으로 리스트 UI를 다시 구성
    private func reloadOptions() {
        // 기존 뷰 제거 (재사용 대신 매번 새로 그림)
        stackView.arrangedSubviews.forEach { subview in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        // 각 item에 대해 row 생성 후 stackView에 추가
        for index in items.indices {
            let item = items[index]
            let rowView = makeOptionRow(for: item)
            stackView.addArrangedSubview(rowView)

            if index < items.count - 1 {
                let divider = makeDividerView()
                stackView.addArrangedSubview(divider)
            }
        }
    }

    // 개별 옵션 row 생성
    private func makeOptionRow(for item: OptionPopupItem) -> UIControl {
        let rowControl = UIControl()
        // row 전체를 터치 영역으로 사용하는 컨트롤 (각 옵션 한 줄)
        rowControl.backgroundColor = .clear
        rowControl.tag = items.firstIndex(of: item) ?? 0
        rowControl.addTarget(self, action: #selector(didTapOptionRow(_:)), for: .touchUpInside)

        // 선택 상태를 표시하는 체크마크 (항상 자리 차지, alpha로만 표시/숨김)
        let checkImageView = UIImageView()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        checkImageView.image = UIImage(systemName: "checkmark", withConfiguration: symbolConfig)
        checkImageView.tintColor = Colors.Text.main
        checkImageView.contentMode = .scaleAspectFit
        let isSelected = item.id == selectedItemID
        checkImageView.isHidden = false
        checkImageView.alpha = isSelected ? 1.0 : 0.0

        // 옵션 텍스트 라벨
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = Fonts.body
        titleLabel.textColor = Colors.Text.main
        titleLabel.numberOfLines = 1

        // 체크마크 + 텍스트 + spacer를 가로로 배치하는 스택
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .fill
        hStack.spacing = 16

        let spacerView = UIView()

        rowControl.addSubview(hStack)
        hStack.addArrangedSubview(checkImageView)
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(spacerView)
        
        // 내부 스택이 터치를 가로채지 않도록 비활성화 (rowControl이 전체 터치 처리)
        hStack.isUserInteractionEnabled = false

        // 각 row 높이 (터치 영역 포함)
        rowControl.snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        // 내부 콘텐츠 여백 (좌우 padding)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }

        // 체크마크 아이콘 크기
        checkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }

        // 터치 다운 시 하이라이트 효과
        rowControl.addAction(UIAction { [weak rowControl] _ in
            rowControl?.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        }, for: .touchDown)

        // 터치 종료/취소 시 하이라이트 해제
        rowControl.addAction(UIAction { [weak rowControl] _ in
            rowControl?.backgroundColor = .clear
        }, for: [.touchCancel, .touchDragExit, .touchUpInside, .touchUpOutside])

        return rowControl
    }

    // row 사이 구분선 생성
    private func makeDividerView() -> UIView {
        let dividerView = UIView()
        dividerView.backgroundColor = .systemGray5

        // divider를 감싸는 wrapper (좌우 inset 처리용)
        let wrapperView = UIView()
        wrapperView.addSubview(dividerView)

        wrapperView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        dividerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(36)
            make.trailing.equalToSuperview().inset(24)
        }

        return wrapperView
    }

    // 옵션 선택 시 호출되는 액션
    @objc private func didTapOptionRow(_ sender: UIControl) {
        guard sender.tag < items.count else { return }
        let selectedItem = items[sender.tag]
        // 선택 상태 업데이트 후 UI 다시 그림
        selectedItemID = selectedItem.id
        reloadOptions()
        // 외부로 선택된 아이템 전달
        onSelectItem?(selectedItem)
    }
}
