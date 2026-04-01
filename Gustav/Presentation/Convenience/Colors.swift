//
//  Colors.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/3.
//

import UIKit

// MARK: - 앱 색상
struct Colors {
    
    // 앱 테마 색상
    struct Theme {
        // Primary Color (Yellow)
        static let primary: UIColor = UIColor(named: "PrimaryThemeColor")!
        // Text Background Color (Gray)
        static let textBackground: UIColor = UIColor(named: "TextBackgroundColor")!
        // Outline Color (Gray)
        static let outline: UIColor = UIColor(named: "OutlineColor")!
        // Card Background Color (White)
        static let cardBackground: UIColor = UIColor(named: "CardBackgroundColor")!
        // Main Background Color (Light Gray)
        static let mainBackground: UIColor = UIColor.systemGray6
        // Inactive Color (Gray)
        static let inactive: UIColor = UIColor(named: "InactiveColor")!
        // Red Color (Red)
        static let red: UIColor = UIColor.red
        
        private init() {}
    }
    
    // 앱 텍스트 색상
    struct Text {
        // Main Color
        static let main: UIColor = UIColor(named: "MainTextColor")!
        // Additional Information Color
        static let additionalInfo: UIColor = UIColor(named: "AdditionalInfoTextColor")!
        // Red Color (Red)
        static let red: UIColor = UIColor.red
        // Green Color (Green)
        static let green: UIColor = UIColor.green
        // Error Color
        static let error: UIColor = UIColor(named: "ErrorColor")!
        // Highlighted Item Property Color (Gold)
        static let highlighted: UIColor = UIColor(named: "HighlightedPropertyColor")!
        
        private init() {}
    }
    
    private init() {}
}

// MARK: - TagColor Extensions
extension TagColor {
    // 태그 컬러에 해당하는 UIColor 배경 색상 반환
    func toUIColor() -> UIColor {
        switch self {
        case .darkGray:
            return UIColor.darkGray.withAlphaComponent(0.3)
        case .lightGray:
            return UIColor.lightGray.withAlphaComponent(0.3)
        case .brown:
            return UIColor.brown.withAlphaComponent(0.3)
        case .red:
            return UIColor.red.withAlphaComponent(0.3)
        case .orange:
            return UIColor.orange.withAlphaComponent(0.3)
        case .yellow:
            return UIColor.yellow.withAlphaComponent(0.3)
        case .green:
            return UIColor.green.withAlphaComponent(0.3)
        case .blue:
            return UIColor.blue.withAlphaComponent(0.3)
        case .pink:
            return UIColor.systemPink.withAlphaComponent(0.3)
        case .purple:
            return UIColor.purple.withAlphaComponent(0.3)
        }
    }
    // 배경에 따른 텍스트 색상 반환
    func getTextColor() -> UIColor {
        switch self {
        case .darkGray:
            return UIColor.darkGray
        case .lightGray:
            return UIColor.lightGray
        case .brown:
            return UIColor.brown
        case .red:
            return UIColor.red
        case .orange:
            return UIColor.orange
        case .yellow:
            return UIColor.yellow
        case .green:
            return UIColor.green
        case .blue:
            return UIColor.blue
        case .pink:
            return UIColor.systemPink
        case .purple:
            return UIColor.purple
        }
    }
}
