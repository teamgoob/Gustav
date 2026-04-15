//
//  AppEnvironment.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/12.
//

import Foundation

enum AppEnvironment {
    static var authCallbackURL: URL {
        guard let url = URL(string: "gustav://auth/callback") else {
            fatalError("Invalid auth callback URL")
        }
        return url
    }

    static var passwordResetURL: URL {
        guard let url = URL(string: "gustav://auth/reset-password") else {
            fatalError("Invalid password reset URL")
        }
        return url
    }

    static var supabaseURL: URL {
        guard let urlString = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_URL"
        ) as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not configured")
        }
        
        
        
        return url
    }
    
    static var supabaseFunctionsURL: URL {
        supabaseURL
            .appendingPathComponent("functions")
            .appendingPathComponent("v1")
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
