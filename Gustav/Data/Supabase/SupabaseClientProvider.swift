//
//  SupabaseClientProvider.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/12.
//

import Supabase

protocol SupabaseClientProviding {
    var client: SupabaseClient { get }
}


// MARK: - SupabaseClientProvider
// SupabaseClient 생성
//enum SupabaseClientProvider: SupabaseClientProviding {
//    static func create() -> SupabaseClient {
//        // AppEnvironment에서 가져온 URL, Key 사용
//        SupabaseClient(
//            supabaseURL: AppEnvironment.supabaseURL,
//            supabaseKey: AppEnvironment.supabaseKey
//        )
//    }
//}

final class SupabaseClientProvider: SupabaseClientProviding {

    let client: SupabaseClient
    // AppEnvironment에서 가져온 URL, Key 사용
    init() {
        self.client = SupabaseClient(
            supabaseURL: AppEnvironment.supabaseURL,
            supabaseKey: AppEnvironment.supabaseKey
        )
    }
}
/// song
/// 나중에 로그인 테스트랑 레포지토리 주입 DI 때문에 final class로 했습니다
