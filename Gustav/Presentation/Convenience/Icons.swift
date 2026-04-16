//
//  Icons.swift
//  Gustav
//
//  Created by 최명수 on 2026/3/3.
//

import UIKit

// MARK: - 앱 아이콘
struct Icons {
    
    // Profile Icon
    static let profile: UIImage? = UIImage(systemName: "person.crop.circle")
    
    // Information Icon
    static let info: UIImage? = UIImage(systemName: "info.circle")
    
    // Policy Icon
    static let policy: UIImage? = UIImage(systemName: "list.bullet.clipboard")
    
    // Sign Out Icon
    static let signOut: UIImage? = UIImage(systemName: "rectangle.portrait.and.arrow.forward")
    
    // Delete Icon
    static let delete: UIImage? = UIImage(systemName: "trash")
    
    // Email Icon
    static let email: UIImage? = UIImage(systemName: "envelope.fill")
    
    // Password Icon
    static let password: UIImage? = UIImage(systemName: "lock.fill")
    
    // Category Icon
    static let category: UIImage? = UIImage(systemName: "tag")
    
    // Location Icon
    static let location: UIImage? = UIImage(systemName: "location")
    
    // Item State Icon
    static let itemState: UIImage? = UIImage(systemName: "arrow.triangle.2.circlepath")
    
    // View Preset icon
    static let viewPreset: UIImage? = UIImage(systemName: "rectangle.3.group")
    
    // Bulk Icon
    static let bulk: UIImage? = UIImage(systemName: "square.3.layers.3d.down.right")
    
    // Last Modified Date Icon
    static let lastModified: UIImage? = UIImage(systemName: "calendar.badge.clock")?.applyingSymbolConfiguration(.init(paletteColors: [Colors.Theme.green.withAlphaComponent(0.4), Colors.Text.main]))
    
    // Created Date Icon
    static let created: UIImage? = UIImage(systemName: "calendar.badge.plus")?.applyingSymbolConfiguration(.init(paletteColors: [Colors.Theme.green.withAlphaComponent(0.4), Colors.Text.main]))
    
    // Name Icon
    static let name: UIImage? = UIImage(systemName: "cube.box")
    
    // Name Detail Icon
    static let nameDetail: UIImage? = UIImage(systemName: "text.alignleft")
    
    // Purchase Date Icon
    static let purchaseDate: UIImage? = UIImage(systemName: "calendar.badge.checkmark")?.applyingSymbolConfiguration(.init(paletteColors: [Colors.Theme.green.withAlphaComponent(0.4), Colors.Text.main]))
    
    // Purchase Place Icon
    static let purchasePlace: UIImage? = UIImage(systemName: "storefront")
    
    // Expiration Date Icon
    static let expiration: UIImage? = UIImage(systemName: "calendar.badge.exclamationmark")?.applyingSymbolConfiguration(.init(paletteColors: [Colors.Theme.red.withAlphaComponent(0.5), Colors.Text.main]))
    
    // Price Icon
    static let price: UIImage? = UIImage(systemName: "creditcard")
    
    // Quantity Icon
    static let quantity: UIImage? = UIImage(systemName: "number")
    
    // Ascending Icon
    static let ascending: UIImage? = UIImage(systemName: "arrow.up.to.line")
    
    // Descending Icon
    static let descending: UIImage? = UIImage(systemName: "arrow.down.to.line")
    
    // Color Circle Icon
    static let colorCircle: UIImage? = UIImage(systemName: "circle.fill")

    static func tagColorCircle(_ color: TagColor?) -> UIImage? {
        guard let color else { return nil }
        return colorCircle?.withTintColor(color.toUIColor(), renderingMode: .alwaysOriginal)
    }

    private init() {}
}
