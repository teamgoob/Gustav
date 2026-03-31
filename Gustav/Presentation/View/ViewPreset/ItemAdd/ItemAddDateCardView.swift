//
//  ItemAddDateCardView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit
import SnapKit

final class ItemAddDateCardView: UIView {

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

    // MARK: - UI
    private let cardView = UIView()

    private let topRowStackView = UIStackView()
    private let bottomRowStackView = UIStackView()
    private let dateValueStackView = UIStackView()

    private let toggleTitleLabel = UILabel()
    private let dateTitleLabel = UILabel()

    let toggleSwitch = UISwitch()
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()

    // MARK: - Callbacks
    var onSwitchChanged: ((Bool) -> Void)?
    var onDateChanged: ((Date) -> Void)?
    var onTimeChanged: ((Date) -> Void)?

    // MARK: - Actions
    @objc private func didChangeSwitch(_ sender: UISwitch) {
        let isOn = sender.isOn
        applyEnabledState(isOn: isOn, animated: true)
        onSwitchChanged?(isOn)
    }

    @objc private func didChangeDatePicker(_ sender: UIDatePicker) {
        guard toggleSwitch.isOn else { return }
        onDateChanged?(sender.date)
    }

    @objc private func didChangeTimePicker(_ sender: UIDatePicker) {
        guard toggleSwitch.isOn else { return }
        onTimeChanged?(sender.date)
    }

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
    init(configuration: Configuration) {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        configure(configuration)
        applyEnabledState(isOn: configuration.isOn, animated: false)
    }

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

    func setSwitchOn(_ isOn: Bool, animated: Bool) {
        toggleSwitch.setOn(isOn, animated: animated)
        applyEnabledState(isOn: isOn, animated: animated)
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        setupCardView()
        setupStackViews()
        setupLabels()
        setupSwitch()
        setupDatePicker(datePicker)
        setupTimePicker(timePicker)

        addSubview(cardView)

        cardView.addSubview(topRowStackView)
        cardView.addSubview(bottomRowStackView)

        topRowStackView.addArrangedSubview(toggleTitleLabel)
        topRowStackView.addArrangedSubview(toggleSwitch)

        bottomRowStackView.addArrangedSubview(dateTitleLabel)
        bottomRowStackView.addArrangedSubview(dateValueStackView)

        dateValueStackView.addArrangedSubview(datePicker)
        dateValueStackView.addArrangedSubview(timePicker)

        datePicker.addTarget(self, action: #selector(didChangeDatePicker(_:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(didChangeTimePicker(_:)), for: .valueChanged)
    }

    private func setupCardView() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
    }

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

    private func setupLabels() {
        [toggleTitleLabel, dateTitleLabel].forEach {
            $0.font = Fonts.body
            $0.textColor = Colors.Text.main
            $0.numberOfLines = 1
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }

    private func setupSwitch() {
        toggleSwitch.setContentHuggingPriority(.required, for: .horizontal)
        toggleSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggleSwitch.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
    }

    private func setupDatePicker(_ picker: UIDatePicker) {
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "en_US_POSIX")
        picker.tintColor = Colors.Text.main
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setupTimePicker(_ picker: UIDatePicker) {
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "en_US_POSIX")
        picker.tintColor = Colors.Text.main
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setupLayout() {
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topRowStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        toggleSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(toggleTitleLabel.snp.centerY)
        }
        toggleTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(toggleSwitch.snp.centerY)
        }

        bottomRowStackView.snp.makeConstraints { make in
            make.top.equalTo(topRowStackView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(18)
        }

//        datePicker.snp.makeConstraints { make in
//            make.height.equalTo(36)
//        }
//
//        timePicker.snp.makeConstraints { make in
//            make.height.equalTo(36)
//        }
    }
}

#if DEBUG
import SwiftUI

private struct ItemAddDateCardViewRepresentable: UIViewRepresentable {

    let configuration: ItemAddDateCardView.Configuration

    func makeUIView(context: Context) -> ItemAddDateCardView {
        ItemAddDateCardView(configuration: configuration)
    }

    func updateUIView(_ uiView: ItemAddDateCardView, context: Context) {
        uiView.configure(configuration)
    }
}

#Preview {
    VStack(spacing: 24) {
        ItemAddDateCardViewRepresentable(
            configuration: .init(
                toggleTitle: "Purchase date",
                dateTitle: "date",
                dateText: "Apr 1, 2025",
                timeText: "9:41 AM",
                isOn: true
            )
        )
        .frame(height: 140)

        ItemAddDateCardViewRepresentable(
            configuration: .init(
                toggleTitle: "date",
                dateTitle: "date",
                dateText: "Apr 1, 2025",
                timeText: "9:41 AM",
                isOn: true
            )
        )
        .frame(height: 140)
    }
    .padding(32)
    .background(Color(uiColor: .systemGray6))
}
#endif
