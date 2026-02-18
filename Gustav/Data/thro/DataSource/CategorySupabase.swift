//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class SupabaseCategoryRemoteDataSource: CategoryDataSourceProtocol {
    // 클라이언트
    private let client: SupabaseClient
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    func fetchCategories(workspaceId: UUID) async -> RepositoryResult<[CategoryDTO]> {
        do {
            let response = try await client
                .from("categories")
                .select()
                .eq("workspace_id", value: workspaceId)
                .order("index_key")
                .execute()
            let data = response.data
            do {
                let categories = try JSONDecoder().decode([CategoryDTO].self, from: data)
                return .success(categories)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("fetchCategories Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
        
    }
    
    func fetchCategory(id: UUID) async -> RepositoryResult<CategoryDTO> {
        do {
            let response = try await client
                .from("categories")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
            let data = response.data
            do {
                let category = try JSONDecoder().decode(CategoryDTO.self, from: data)
                return .success(category)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("fetchCategory Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func createCategory(categoryDTO: CategoryDTO) async -> RepositoryResult<CategoryDTO> {
        do {
            let response = try await client
                .from("categories")
                .insert(categoryDTO)
                .select()
                .single()
                .execute()
            let data = response.data
            do {
                let created = try JSONDecoder().decode(CategoryDTO.self, from: data)
                return .success(created)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("CreateCategory Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func updateCategory(id: UUID, dto: CategoryDTO) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from("categories")
                .update(dto)
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            print("updateCategory Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func deleteCategory(id: UUID) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from("categories")
                .delete()
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            print("deleteCategory Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        let offset = 10_000
        do {
            for (index, id) in order.enumerated() {
                _ = try await client
                    .from("categories")
                    .update(["index_key": index +  offset])
                    .eq("id", value: id)
                    .execute()
            }
            for (index, id) in order.enumerated() {
                _ = try await client
                    .from("categories")
                    .update(["index_key": index])
                    .eq("id", value: id)
                    .execute()
            }
            return .success(())
        } catch {
            print("reorderCategories Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
}
