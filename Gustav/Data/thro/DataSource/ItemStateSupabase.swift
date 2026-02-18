//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class SupabaseItemStateRemoteDataSource: ItemStateDataSourceProtocol {
    // 클라이언트
    private let client: SupabaseClient
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    func fetchItemStates(workspaceId: UUID) async -> RepositoryResult<[ItemStateDTO]> {
        do {
            let response = try await client
                .from("states")
                .select()
                .eq("workspace_id", value: workspaceId)
                .order("index_key")
                .execute()
            let data = response.data
            do {
                let states = try JSONDecoder().decode([ItemStateDTO].self, from: data)
                return .success(states)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("fetchCategories Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func fetchItemState(id: UUID) async -> RepositoryResult<ItemStateDTO?> {
        do {
            let response = try await client
                .from("states")
                .select()
                .eq("id", value: id)
                .execute()
            let data = response.data
            do {
                let states = try JSONDecoder().decode(ItemStateDTO?.self, from: data)
                return .success(states)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func createItemState(dto: ItemStateDTO) async -> RepositoryResult<ItemStateDTO> {
        do {
            let response = try await client
                .from("states")
                .insert(dto)
                .select()
                .single()
                .execute()
            let data = response.data
            do {
                let states = try JSONDecoder().decode(ItemStateDTO.self, from: data)
                return .success(states)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
        
    }
    
    func updateItemState(id: UUID, dto: ItemStateDTO) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from("states")
                .update(dto)
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func deleteItemState(id: UUID) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from( "states" )
                .delete()
                .eq( "id", value: id )
                .execute()
            return .success(())
        } catch {
            return .failure(RepositoryError.decoding)
        }
    }
    
    func reorderItemStates(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        let offest = 10_000
        do {
            for (i, id) in order.enumerated() {
                try await client
                    .from("states")
                    .update(["index_key": "\(offest + i)"])
                    .eq("id", value: id)
                    .execute()
            }
            
            for (i, id) in order.enumerated() {
                try await client
                    .from("categories")
                    .update(["index_key": i])
                    .eq("id", value: id)
                    .execute()
            }
            
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
}
