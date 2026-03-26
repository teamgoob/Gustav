//
//  TagLabel.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/26.
//

import UIKit

// MARK: - TagLabel
// UILabel을 상속한 태그 형태의 레이블
final class TagLabel: UILabel {
    // 텍스트 주변 패딩
    private let padding = UIEdgeInsets(
        top: 4,
        left: 10,
        bottom: 4,
        right: 10
    )
    
    // 배경 포함 사이즈 설정
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }
    
    // 패딩 내부에 텍스트 표시
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    // 코너 곡률 설정
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
}
