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
        
        private init() {}
    }
    
    private init() {}
}
