//
//  NotificationName+Extensions.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/13.
//

import Foundation

// MARK: - Notification.Name Extensions
extension Notification.Name {
    // 로그아웃 이벤트
    static let logout = Notification.Name("Gustav.Notification.Name.logout")
    // 회원 탈퇴 이벤트
    static let deleteAccount = Notification.Name("Gustav.Notification.Name.deleteAccount")
}

/* AppCoordinator 구현
 // Initializer 내 호출
 observeAuthEvents()
 
 // 이벤트 구독
 private func observeAuthEvents() {
     NotificationCenter.default.addObserver(
         self,
         selector: #selector(handleLogout),
         name: .logout,
         object: nil
     )
     
     NotificationCenter.default.addObserver(
         self,
         selector: #selector(handleDeleteAccount),
         name: .deleteAccount,
         object: nil
     )
 }

 // 로그아웃 이벤트 처리
 @objc
 private func handleLogout() {
     childCoordinators.removeAll()
     navigationController.setViewControllers([], animated: false)
     // 로그아웃 상태 Flow 시작
     startAuthFlow()
 }

 // 회원 탈퇴 이벤트 처리
 @objc
 private func handleDeleteAccount() {
     childCoordinators.removeAll()
     navigationController.setViewControllers([], animated: false)
     // 로그아웃 상태 Flow 시작
     startAuthFlow()
 }
 
 // Observer 해제
 deinit {
     NotificationCenter.default.removeObserver(self)
 }
 */
