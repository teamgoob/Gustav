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
    // 카드 배경과 입력 영역(UITextView), placeholder 라벨

    // 카드 형태의 배경 뷰
    private let cardView = UIView()

    // 메모 입력용 텍스트뷰
    private let textView = UITextView()

    // placeholder 표시용 라벨
    private let placeholderLabel = UILabel()

    // MARK: - Callback
    // 텍스트가 변경될 때 외부로 전달하는 클로저
    var onTextChanged: ((String) -> Void)?

    // MARK: - Init
    // 기본 생성자 - UI 및 레이아웃 초기 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    // 현재 텍스트 값을 외부에서 읽거나 설정합니다.
    var text: String? {
        get { textView.text }
        set {
            textView.text = newValue
            updatePlaceholder()
        }
    }

    // placeholder 텍스트를 설정합니다.
    func setPlaceholder(_ text: String) {
        placeholderLabel.text = text
    }
    
    // MARK: - Setup
    // UI 구성 및 기본 스타일 설정
    private func setupUI() {
        // 뷰 기본 배경
        backgroundColor = .clear

        // 카드 스타일 적용
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true

        // 텍스트뷰 기본 스타일 및 delegate 연결
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.isScrollEnabled = false
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.delegate = self

        // placeholder 스타일 설정
        placeholderLabel.font = Fonts.body
        placeholderLabel.textColor = Colors.Text.additionalInfo

        // 뷰 계층 구성
        addSubview(cardView)
        cardView.addSubview(textView)
        cardView.addSubview(placeholderLabel)
    }

    // MARK: - Layout
    // SnapKit을 이용한 레이아웃 설정
    private func setupLayout() {
        // 카드가 전체 영역을 채우도록 설정
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 텍스트 입력 영역 padding 적용
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        // placeholder 위치 설정
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(20)
        }
    }

    // MARK: - Private
    // 내부 상태 업데이트 및 사이즈 계산
    private func updatePlaceholder() {
        // 텍스트 여부에 따라 placeholder 표시/숨김 처리
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }
    
    override var intrinsicContentSize: CGSize {
        // 텍스트 길이에 따라 높이 자동 조정
        let height = textView.contentSize.height + 32 // padding 고려
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

// MARK: - UITextViewDelegate
// 텍스트 변경 감지 및 외부 이벤트 전달
extension ItemMemoCardView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // placeholder 상태 갱신
        updatePlaceholder()
        // 높이 재계산 트리거
        invalidateIntrinsicContentSize()
        // 외부로 텍스트 변경 전달
        onTextChanged?(textView.text)
    }

}
