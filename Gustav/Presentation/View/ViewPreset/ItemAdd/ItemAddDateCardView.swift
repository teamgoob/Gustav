//
//  ItemAddDateCardView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit
import SnapKit

final class ItemAddDateCardView: UIView {

    // MARK: - Types

    // 카드 초기 상태와 표시 문자열을 전달하기 위한 설정값입니다.
    struct Configuration {
        let toggleTitle: String
        let dateTitle: String
        let dateText: String?
        let timeText: String?
        let isOn: Bool

        init(
            toggleTitle: String,
            dateTitle: String,
            dateText: String?,
            timeText: String?,
            isOn: Bool = true
        ) {
            self.toggleTitle = toggleTitle
            self.dateTitle = dateTitle
            self.dateText = dateText
            self.timeText = timeText
            self.isOn = isOn
        }
    }

    // MARK: - Public
    // 날짜 사용 스위치의 현재 상태를 반환합니다.
    var isDateEnabled: Bool {
        toggleSwitch.isOn
    }

    // 선택된 날짜 값을 반환합니다.
    var selectedDate: Date {
        datePicker.date
    }

    // 선택된 시간 값을 반환합니다.
    var selectedTime: Date {
        timePicker.date
    }

    // 스위치 상태, 날짜, 시간을 도메인 입력 모델로 묶어서 반환합니다.
    var selectedValue: ItemDateInput {
        ItemDateInput(
            isEnabled: toggleSwitch.isOn,
            date: datePicker.date,
            time: timePicker.date
        )
    }

    // MARK: - UI
    // 카드 배경 컨테이너
    private let cardView = UIView()

    // 상단 행, 하단 행, 날짜/시간 값 영역 스택뷰
    private let topRowStackView = UIStackView()
    private let bottomRowStackView = UIStackView()
    private let dateValueStackView = UIStackView()

    // 표시용 라벨
    private let toggleTitleLabel = UILabel()
    private let dateTitleLabel = UILabel()

    // 사용자 입력 컨트롤
    let toggleSwitch = UISwitch()
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()

    // MARK: - Callbacks
    // 스위치 상태가 바뀌었을 때 외부로 전달합니다.
    var onSwitchChanged: ((Bool) -> Void)?
    // 날짜가 바뀌었을 때 외부로 전달합니다.
    var onDateChanged: ((Date) -> Void)?
    // 시간이 바뀌었을 때 외부로 전달합니다.
    var onTimeChanged: ((Date) -> Void)?

    // MARK: - Actions
    // 스위치 값이 바뀌면 내부 UI 상태를 반영하고 외부로 이벤트를 전달합니다.
    @objc private func didChangeSwitch(_ sender: UISwitch) {
        let isOn = sender.isOn
        applyEnabledState(isOn: isOn, animated: true)
        onSwitchChanged?(isOn)
    }

    // 날짜가 바뀌었을 때, 스위치가 켜져 있으면 외부로 전달합니다.
    @objc private func didChangeDatePicker(_ sender: UIDatePicker) {
        guard toggleSwitch.isOn else { return }
        onDateChanged?(sender.date)
    }

    // 시간이 바뀌었을 때, 스위치가 켜져 있으면 외부로 전달합니다.
    @objc private func didChangeTimePicker(_ sender: UIDatePicker) {
        guard toggleSwitch.isOn else { return }
        onTimeChanged?(sender.date)
    }

    // 스위치 상태에 따라 날짜/시간 영역의 활성화와 시각적 상태를 반영합니다.
    private func applyEnabledState(isOn: Bool, animated: Bool) {
        datePicker.isEnabled = isOn
        timePicker.isEnabled = isOn

        let alpha: CGFloat = isOn ? 1.0 : 0.4
        let animations = {
            self.bottomRowStackView.alpha = alpha
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }

    // MARK: - Init
    // 설정값을 받아 초기 상태까지 반영하는 생성자입니다.
    init(configuration: Configuration) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        configure(configuration)
        applyEnabledState(isOn: configuration.isOn, animated: false)
    }

    // 기본 상태로 뷰를 생성하는 생성자입니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        applyEnabledState(isOn: toggleSwitch.isOn, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    // 외부에서 날짜, 시간, 스위치 상태를 한 번에 업데이트합니다.
    func update(date: Date, time: Date, isOn: Bool) {
        datePicker.date = date
        timePicker.date = time
        setSwitchOn(isOn, animated: false)
    }

    // 전달받은 설정값으로 라벨 텍스트와 picker의 초기 값을 반영합니다.
    func configure(_ configuration: Configuration) {
        toggleTitleLabel.text = configuration.toggleTitle
        dateTitleLabel.text = configuration.dateTitle

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let dateText = configuration.dateText, !dateText.isEmpty {
            formatter.dateFormat = "MMM d, yyyy"
            if let date = formatter.date(from: dateText) {
                datePicker.date = date
            } else {
                datePicker.date = Date()
            }
        } else {
            datePicker.date = Date()
        }

        if let timeText = configuration.timeText, !timeText.isEmpty {
            formatter.dateFormat = "h:mm a"
            if let time = formatter.date(from: timeText) {
                timePicker.date = time
            } else {
                timePicker.date = Date()
            }
        } else {
            timePicker.date = Date()
        }

        toggleSwitch.isOn = configuration.isOn
        applyEnabledState(isOn: configuration.isOn, animated: false)
    }

    // 외부에서 스위치 상태를 변경하고, 관련 UI 상태도 함께 반영합니다.
    func setSwitchOn(_ isOn: Bool, animated: Bool) {
        toggleSwitch.setOn(isOn, animated: animated)
        applyEnabledState(isOn: isOn, animated: animated)
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        // 카드와 하위 뷰들의 기본 스타일을 설정
        setupCardView()
        setupStackViews()
        setupLabels()
        setupSwitch()
        setupDatePicker(datePicker)
        setupTimePicker(timePicker)

        addSubview(cardView)

        // 카드 내부에 상단/하단 행을 배치
        cardView.addSubview(topRowStackView)
        cardView.addSubview(bottomRowStackView)

        // 상단 행: 제목 + 스위치
        topRowStackView.addArrangedSubview(toggleTitleLabel)
        topRowStackView.addArrangedSubview(toggleSwitch)

        // 하단 행: 날짜 라벨 + 날짜/시간 선택 영역
        bottomRowStackView.addArrangedSubview(dateTitleLabel)
        bottomRowStackView.addArrangedSubview(dateValueStackView)

        // 날짜/시간 선택 영역 내부 구성
        dateValueStackView.addArrangedSubview(datePicker)
        dateValueStackView.addArrangedSubview(timePicker)

        // 사용자 입력 이벤트 연결
        datePicker.addTarget(self, action: #selector(didChangeDatePicker(_:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(didChangeTimePicker(_:)), for: .valueChanged)
    }

    // 카드 배경 뷰의 색상과 둥근 모서리를 설정합니다.
    private func setupCardView() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
    }

    // 각 스택뷰의 축, 정렬, 간격을 설정합니다.
    private func setupStackViews() {
        topRowStackView.axis = .horizontal
        topRowStackView.alignment = .fill
        topRowStackView.distribution = .fill
        topRowStackView.spacing = 12

        bottomRowStackView.axis = .horizontal
        bottomRowStackView.alignment = .center
        bottomRowStackView.distribution = .equalSpacing

        dateValueStackView.axis = .horizontal
        dateValueStackView.alignment = .center
        dateValueStackView.spacing = 8
    }

    // 라벨들의 공통 폰트와 우선순위를 설정합니다.
    private func setupLabels() {
        [toggleTitleLabel, dateTitleLabel].forEach {
            $0.font = Fonts.body
            $0.textColor = Colors.Text.main
            $0.numberOfLines = 1
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }

    // 스위치의 우선순위와 값 변경 이벤트를 설정합니다.
    private func setupSwitch() {
        toggleSwitch.setContentHuggingPriority(.required, for: .horizontal)
        toggleSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggleSwitch.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
    }

    // 날짜 선택 picker의 모드와 스타일을 설정합니다.
    private func setupDatePicker(_ picker: UIDatePicker) {
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "en_US_POSIX")
        picker.tintColor = Colors.Text.main
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    // 시간 선택 picker의 모드와 스타일을 설정합니다.
    private func setupTimePicker(_ picker: UIDatePicker) {
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "en_US_POSIX")
        picker.tintColor = Colors.Text.main
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    // 카드 내부 레이아웃과 간격을 설정합니다.
    private func setupLayout() {
        // 카드 뷰가 현재 뷰를 가득 채우도록 설정
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 상단 행은 카드 상단에 배치하고 좌우 여백을 둡니다.
        topRowStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        // 스위치와 제목 라벨의 세로 중심을 맞춥니다.
        toggleSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(toggleTitleLabel.snp.centerY)
        }

        toggleTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(toggleSwitch.snp.centerY)
        }

        // 하단 행은 상단 행 아래에 배치하고 카드 하단 여백을 둡니다.
        bottomRowStackView.snp.makeConstraints { make in
            make.top.equalTo(topRowStackView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(18)
        }
    }
}
