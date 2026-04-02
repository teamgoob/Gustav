//
//  DropdownOverlayManager.swift
//  Gustav
//
//  Created by kaeun on 4/3/26.
//

import UIKit
import SnapKit


// MARK: - DropdownOverlayManager

/// row(anchor view) 기준으로 custom dropdown popup을 표시하는 재사용 가능한 UI 헬퍼 객체
/// 역할:
/// - overlay 표시 / 제거
/// - anchor view 좌표 변환
/// - popup의 위/아래 배치 계산
/// - 바깥 영역 터치 dismiss 처리
final class DropdownOverlayManager {
    
    // MARK: - Properties
    
    /// dropdown popup을 표시할 기준 ViewController
    private weak var hostViewController: UIViewController?
    
    /// 바깥 영역 터치와 dismiss를 처리하는 overlay view
    private let overlayView = UIControl()
    
    /// 실제 dropdown popup content를 담는 컨테이너
    private let containerView = UIView()
    
    // MARK: - Init
    
    init(hostViewController: UIViewController) {
        self.hostViewController = hostViewController
        setupUI()
    }
    
    // MARK: - Public
    
    /// anchor view 기준으로 dropdown popup을 표시합니다.
    func present(contentView: UIView, from anchorView: UIView, preferredSize: CGSize) {
        dismiss(animated: false)
        
        guard let hostView = hostViewController?.view else { return }
        let anchorFrame = convertedAnchorFrame(from: anchorView, in: hostView)
        
        let horizontalInset: CGFloat = 24
        let verticalSpacing: CGFloat = 8
        let maxWidth = hostView.bounds.width - (horizontalInset * 2)
        let width = min(preferredSize.width, maxWidth)
        let height = preferredSize.height
        let originX = min(
            max(anchorFrame.minX, horizontalInset),
            hostView.bounds.width - horizontalInset - width
        )
        
        let topSafeY = hostView.safeAreaInsets.top + 8
        let bottomSafeY = hostView.bounds.height - hostView.safeAreaInsets.bottom - 8
        let fitsAbove = anchorFrame.minY - verticalSpacing - height >= topSafeY
        
        let originY: CGFloat
        if fitsAbove {
            originY = anchorFrame.minY - verticalSpacing - height
        } else {
            originY = min(anchorFrame.maxY + verticalSpacing, bottomSafeY - height)
        }
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.frame = CGRect(x: originX, y: originY, width: width, height: height)
        containerView.addSubview(contentView)
        contentView.frame = containerView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        overlayView.isHidden = false
        containerView.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.overlayView.alpha = 1
            self.containerView.alpha = 1
        }
    }
    
    /// 현재 표시 중인 dropdown popup을 제거합니다.
    func dismiss(animated: Bool) {
        let completion = {
            self.overlayView.isHidden = true
            self.overlayView.alpha = 0
            self.containerView.isHidden = true
            self.containerView.alpha = 0
            self.containerView.subviews.forEach { $0.removeFromSuperview() }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.overlayView.alpha = 0
                self.containerView.alpha = 0
            }, completion: { _ in
                completion()
            })
        } else {
            completion()
        }
    }
    
    // MARK: - Private
    
    /// overlay / container 기본 구성을 설정합니다.
    private func setupUI() {
        guard let hostView = hostViewController?.view else { return }
        
        overlayView.backgroundColor = .clear
        overlayView.isHidden = true
        overlayView.alpha = 0
        overlayView.addTarget(self, action: #selector(didTapOverlay), for: .touchUpInside)
        
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = false
        containerView.isHidden = true
        containerView.alpha = 0
        
        hostView.addSubview(overlayView)
        hostView.addSubview(containerView)
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// anchor view의 frame을 host view 좌표계로 변환합니다.
    private func convertedAnchorFrame(from anchorView: UIView, in hostView: UIView) -> CGRect {
        guard let superview = anchorView.superview else { return .zero }
        return superview.convert(anchorView.frame, to: hostView)
    }
    
    /// overlay 영역 탭 시 dropdown popup을 닫습니다.
    @objc private func didTapOverlay() {
        dismiss(animated: true)
    }
}
