//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class CategorySupabase: CategoryDataSourceProtocol {
    // 클라이언트
    private let client: SupabaseClient
    private let table = "categories"
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    
    
    func fetchCategories(workspaceId: UUID) async -> RepositoryResult<[CategoryDTO]> {
        do {
            let response: [CategoryDTO] = try await client
                .from(table)
                .select()
                .eq("workspace_id", value: workspaceId)
                .order("index_key")
                .execute()
                .value
            return .success(response)
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
        
    }
    
    func fetchCategory(id: UUID) async -> RepositoryResult<CategoryDTO> {
        do {
            let response: CategoryDTO = try await client
                .from(table)
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            return .success(response)
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            return .failure(.unknown)
        }
    }
    
    func createCategory(category: Category) async -> RepositoryResult<CategoryDTO> {
        let categoryDTO = CategoryDTO(
            id: category.id,
            workspaceId: category.workspaceId,
            parentId: category.parentId,
            indexKey: category.indexKey,
            name: category.name,
            color: category.color.rawValue,
            createdAt: Date(),
            updatedAt: nil
        )
        do {
            let response: CategoryDTO = try await client
                .from(table)
                .insert(categoryDTO)
                .select()
                .single()
                .execute()
                .value
            return .success(response)
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            return .failure(.unknown)
        }
    }
    
    func updateCategory(id: UUID, category: Category) async -> RepositoryResult<Void> {
        let categoryDTO = CategoryDTO(
            id: category.id,
            workspaceId: category.workspaceId,
            parentId: category.parentId,
            indexKey: category.indexKey,
            name: category.name,
            color: category.color.rawValue,
            createdAt: nil,
            updatedAt: Date()
        )
        do {
            _ = try await client
                .from(table)
                .update(categoryDTO)
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            return .failure(.unknown)
        }
    }
    
    func deleteCategory(id: UUID) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from(table)
                .delete()
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            return .failure(.unknown)
        }
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        let offset = 10_000
        do {
            for (index, id) in order.enumerated() {
                _ = try await client
                    .from(table)
                    .update(["index_key": index +  offset])
                    .eq("id", value: id)
                    .execute()
            }
            for (index, id) in order.enumerated() {
                _ = try await client
                    .from(table)
                    .update(["index_key": index])
                    .eq("id", value: id)
                    .execute()
            }
            return .success(())
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            return .failure(.unknown)
        }
    }
}
