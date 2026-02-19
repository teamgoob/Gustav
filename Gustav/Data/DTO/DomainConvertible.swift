//
//  DomainConvertible.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation

// MARK: - DomainConvertible 프로토콜
// DTO -> Entity 변환을 위한 프로토콜
protocol DomainConvertible {
    associatedtype DomainType
    func toDomain() -> DomainType
}
