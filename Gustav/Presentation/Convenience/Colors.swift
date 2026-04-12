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
        // Green Color (Green)
        static let green: UIColor = UIColor.green
        
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
    
    // 태그에 사용되는 색상
    struct Tag {
        // 태그 배경 색상
        struct Background {
            // Dark Gray
            static let darkGray: UIColor = UIColor(named: "DarkGrayTagBackgroundColor")!
            // Light Gray
            static let lightGray: UIColor = UIColor(named: "LightGrayTagBackgroundColor")!
            // Brown
            static let brown: UIColor = UIColor(named: "BrownTagBackgroundColor")!
            // Red
            static let red: UIColor = UIColor(named: "RedTagBackgroundColor")!
            // Orange
            static let orange: UIColor = UIColor(named: "OrangeTagBackgroundColor")!
            // Yellow
            static let yellow: UIColor = UIColor(named: "YellowTagBackgroundColor")!
            // Green
            static let green: UIColor = UIColor(named: "GreenTagBackgroundColor")!
            // Blue
            static let blue: UIColor = UIColor(named: "BlueTagBackgroundColor")!
            // Pink
            static let pink: UIColor = UIColor(named: "PinkTagBackgroundColor")!
            // Purple
            static let purple: UIColor = UIColor(named: "PurpleTagBackgroundColor")!
            
            private init() {}
        }
        // 태그 텍스트 색상
        struct Text {
            // Dark Gray
            static let darkGray: UIColor = UIColor(named: "DarkGrayTagTextColor")!
            // Light Gray
            static let lightGray: UIColor = UIColor(named: "LightGrayTagTextColor")!
            // Brown
            static let brown: UIColor = UIColor(named: "BrownTagTextColor")!
            // Red
            static let red: UIColor = UIColor(named: "RedTagTextColor")!
            // Orange
            static let orange: UIColor = UIColor(named: "OrangeTagTextColor")!
            // Yellow
            static let yellow: UIColor = UIColor(named: "YellowTagTextColor")!
            // Green
            static let green: UIColor = UIColor(named: "GreenTagTextColor")!
            // Blue
            static let blue: UIColor = UIColor(named: "BlueTagTextColor")!
            // Pink
            static let pink: UIColor = UIColor(named: "PinkTagTextColor")!
            // Purple
            static let purple: UIColor = UIColor(named: "PurpleTagTextColor")!
            
            private init() {}
        }
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
            return Colors.Tag.Background.darkGray.withAlphaComponent(0.6)
        case .lightGray:
            return Colors.Tag.Background.lightGray.withAlphaComponent(0.6)
        case .brown:
            return Colors.Tag.Background.brown.withAlphaComponent(0.6)
        case .red:
            return Colors.Tag.Background.red.withAlphaComponent(0.6)
        case .orange:
            return Colors.Tag.Background.orange.withAlphaComponent(0.6)
        case .yellow:
            return Colors.Tag.Background.yellow.withAlphaComponent(0.6)
        case .green:
            return Colors.Tag.Background.green.withAlphaComponent(0.6)
        case .blue:
            return Colors.Tag.Background.blue.withAlphaComponent(0.6)
        case .pink:
            return Colors.Tag.Background.pink.withAlphaComponent(0.6)
        case .purple:
            return Colors.Tag.Background.purple.withAlphaComponent(0.6)
        }
    }
    // 배경에 따른 텍스트 색상 반환
    func getTextColor() -> UIColor {
        switch self {
        case .darkGray:
            return Colors.Tag.Text.darkGray
        case .lightGray:
            return Colors.Tag.Text.lightGray
        case .brown:
            return Colors.Tag.Text.brown
        case .red:
            return Colors.Tag.Text.red
        case .orange:
            return Colors.Tag.Text.orange
        case .yellow:
            return Colors.Tag.Text.yellow
        case .green:
            return Colors.Tag.Text.green
        case .blue:
            return Colors.Tag.Text.blue
        case .pink:
            return Colors.Tag.Text.pink
        case .purple:
            return Colors.Tag.Text.purple
        }
    }
}
