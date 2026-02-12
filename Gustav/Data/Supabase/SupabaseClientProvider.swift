//
//  SupabaseClientProvider.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/12.
//

import Supabase

// MARK: - SupabaseClientProvider
// SupabaseClient 생성
enum SupabaseClientProvider {
    static func create() -> SupabaseClient {
        // AppEnvironment에서 가져온 URL, Key 사용
        SupabaseClient(
            supabaseURL: AppEnvironment.supabaseURL,
            supabaseKey: AppEnvironment.supabaseKey
        )
    }
}
