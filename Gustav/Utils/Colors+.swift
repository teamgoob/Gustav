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
        case .darkGray:
            return Colors.Tag.Background.darkGray
        case .lightGray:
            return Colors.Tag.Background.lightGray
        case .brown:
            return Colors.Tag.Background.brown
        case .red:
            return Colors.Tag.Background.red
        case .orange:
            return Colors.Tag.Background.orange
        case .yellow:
            return Colors.Tag.Background.yellow
        case .green:
            return Colors.Tag.Background.green
        case .blue:
            return Colors.Tag.Background.blue
        case .pink:
            return Colors.Tag.Background.pink
        case .purple:
            return Colors.Tag.Background.purple
        }
    }
}
