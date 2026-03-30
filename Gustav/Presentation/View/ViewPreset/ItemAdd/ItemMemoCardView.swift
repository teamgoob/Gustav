//
//  ItemMemoCardView.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import UIKit
import SnapKit

final class ItemMemoCardView: UIView {

    // MARK: - UI
    private let cardView = UIView()
    private let textView = UITextView()

    // Placeholder
    private let placeholderLabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    var text: String? {
        get { textView.text }
        set {
            textView.text = newValue
            updatePlaceholder()
        }
    }

    func setPlaceholder(_ text: String) {
        placeholderLabel.text = text
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true

        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.isScrollEnabled = false
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.delegate = self

        placeholderLabel.font = Fonts.body
        placeholderLabel.textColor = Colors.Text.additionalInfo

        addSubview(cardView)
        cardView.addSubview(textView)
        cardView.addSubview(placeholderLabel)
    }

    private func setupLayout() {
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(20)
        }
    }

    private func updatePlaceholder() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }
    
    override var intrinsicContentSize: CGSize {
        let height = textView.contentSize.height + 32 // padding 고려
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

// MARK: - UITextViewDelegate
extension ItemMemoCardView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        invalidateIntrinsicContentSize()
    }
}
