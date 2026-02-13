//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class SupabaseCategoryRemoteDataSource: CategoryDataSourceProtocol {
    
    
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - 카테고리 생성
    func createCategory(categoryDTO: CategoryDTO) async throws -> CategoryDTO {
        // 1) insert 후 생성된 row를 응답으로 받기 위해 select + single
        // 2) execute()는 네트워크 호출을 수행하고, 응답(raw)을 반환
        let response = try await client
            .from("categories")     // 대상 테이블 선택
            .insert(categoryDTO)    // 인서트할 DTO
            .select()               // 생성된 row를 돌려달라고 요청
            .single()               // 단일 row로 받기
            .execute()              // 네트워크 실행

        // 3) SDK 버전에 따라 decoded/value가 없을 수 있으므로,
        //    raw Data를 직접 JSONDecoder로 디코딩한다.
        //    ※ 아래 'response.data'가 컴파일 에러면, response.body / response.rawValue 등으로 이름이 다를 수 있음.
        let data = response.data

        // 4) 디코딩
        let created = try JSONDecoder().decode(CategoryDTO.self, from: data)
        return created
    }
    
    
    // MARK: - 워크스페이스의 카테고리 목록 조회
    func fetchCategories(workspaceId: UUID) async throws -> [CategoryDTO] {
        
        let response = try await client
            .from("categories")                         // 대상 테이블 선택
            .select()                                   // row 조회
            .eq("workspace_id", value: workspaceId)     // workspace_id로 필터링
            .order("index_key")                         // index_key 기준 정렬
            .execute()                                  // 실제 네트워크 요청 수행
        
        let data = response.data
        
        return try JSONDecoder().decode([CategoryDTO].self, from: data)
    }
    
    // MARK: - 단일 카테고리 조회
    func fetchCategory(id: UUID) async throws -> CategoryDTO {
        
        let response = try await client
            .from("categories")                   // 대상 테이블 선택
            .select()                             // row 조회
            .eq("id", value: id)                  // id로 필터링
            .single()                             // index_key 기준 정렬
            .execute()                            // 실제 네트워크 요청 수행
        
        let data = response.data
        
        return try JSONDecoder().decode(CategoryDTO.self, from: data)
    }
    
    // MARK: - 카테고리 수정
    func updateCategory(id: UUID, dto: CategoryDTO) async throws {   // id에 해당하는 카테고리를 dto 값으로 수정하는 비동기 함수
        
        try await client                                             // SupabaseClient 인스턴스 사용
            .from("categories")                                      // "categories" 테이블 선택
            .update(dto)                                             // dto를 JSON으로 인코딩하여 update payload로 사용
            .eq("id", value: id)                                     // WHERE id = ? 조건 추가
            .execute()                                               // 실제 네트워크 요청 실행 (HTTP PATCH)
    }
    
    // MARK: - 카테고리 삭제
    func deleteCategory(id: UUID) async throws {                     // id에 해당하는 카테고리를 삭제하는 비동기 함수
        
        try await client                                             // SupabaseClient 사용
            .from("categories")                                      // "categories" 테이블 선택
            .delete()                                                // DELETE 쿼리 실행 준비
            .eq("id", value: id)                                     // WHERE id = ? 조건
            .execute()                                               // 실제 네트워크 요청 실행 (HTTP DELETE)
    }
    
    // MARK: - 순서 변경 (index_key 업데이트)
    func reorderCategories(workspaceId: UUID, order: [UUID]) async throws { // 전달받은 UUID 배열 순서대로 index_key를 재설정
        
        for (index, id) in order.enumerated() {                      // 배열의 순서를 index와 함께 순회
            
            try await client                                         // SupabaseClient 사용
                .from("categories")                                  // "categories" 테이블 선택
                .update(["index_key": index])                         // index_key 컬럼을 현재 index 값으로 업데이트
                .eq("id", value: id)                                  // WHERE id = 현재 순회 중인 카테고리 id
                .execute()                                            // 네트워크 요청 실행 (각 id마다 1번씩 요청)
        }
    }
}
