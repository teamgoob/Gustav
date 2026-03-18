//
//  Colors+.swift
//  Gustav
//
//  Created by 박선린 on 3/18/26.
//
import UIKit

extension TagColor {
    var uiColor: UIColor {
        switch self {
        case .darkGray: return .systemGray2
        case .lightGray: return .systemGray
        case .brown: return .systemBrown
        case .red: return .systemRed
        case .orange: return .systemOrange
        case .yellow: return .systemYellow
        case .green: return .systemGreen
        case .blue: return .systemBlue
        case .pink: return .systemPink
        case .purple: return .systemPurple
        }
    }
}
