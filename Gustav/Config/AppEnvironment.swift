//
//  AppEnvironment.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/12.
//

import Foundation

enum AppEnvironment {
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_URL"
        ) as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not configured")
        }
        
        
        print("SUPABASE_URL raw =", urlString)
        print("SUPABASE_URL trimmed =", urlString.trimmingCharacters(in: .whitespacesAndNewlines))
        print("SUPABASE_URL host =", URL(string: urlString)?.host as Any)

        guard let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not configured")
        }
        
        
        return url
    }
    
    
    
    static var supabaseKey: String {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_KEY"
        ) as? String else {
            fatalError("SUPABASE_KEY not configured")
        }
        return key
    }
}
