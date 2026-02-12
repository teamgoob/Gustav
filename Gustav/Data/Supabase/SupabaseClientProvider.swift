//
//  SupabaseClientProvider.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/12.
//

import Supabase

// MARK: - SupabaseClientProvider
// SupabaseClient 제공
final class SupabaseClientProvider {
    // 싱글톤 객체 생성
    static let shared = SupabaseClientProvider()
    
    let client: SupabaseClient
    
    private init() {
        // AppEnvironment에서 가져온 URL, Key 사용
        client = SupabaseClient(
            supabaseURL: AppEnvironment.supabaseURL,
            supabaseKey: AppEnvironment.supabaseKey
        )
    }
}
