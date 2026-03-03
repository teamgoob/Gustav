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
        // Primary Color
        static let primary: UIColor = UIColor(named: "PrimaryColor")!
        // Text Background Color
        static let textBackground: UIColor = UIColor(named: "TextBackgroundColor")!
        // Outline Color
        static let outline: UIColor = UIColor(named: "OutlineColor")!
        
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
