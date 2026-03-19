//
//  BaseCoordinator.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

/*
 상속
 Coordinator protocol
         ↓
 BaseCoordinator
         ↓
 AppCoordinator
 
 */


// 공통 기능만 모아둔 부모 클래스
import UIKit

// MARK: - BaseCoordinator
class BaseCoordinator: Coordinator {
    // MARK: - Properties
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Start
    func start() { }
    
    // MARK: - Child Coordinator Management
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
