//
//  Coordinator.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/12.
//

import UIKit

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    // 화면 전환을 위해 Navigation Controller 주입
    var navigationController: UINavigationController { get }
    // 자식 Coordinator 관리
    var childCoordinators: [Coordinator] { get set }
    // Flow 시작 메서드
    func start()
}
