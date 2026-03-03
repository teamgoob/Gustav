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
    private let table = "states"
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    func fetchItemStates(workspaceId: UUID) async -> RepositoryResult<[ItemStateDTO]> {
        do {
            let response: [ItemStateDTO] = try await client
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
    
    func fetchItemState(id: UUID) async -> RepositoryResult<ItemStateDTO> {
        do {
            let response: ItemStateDTO = try await client
                .from(table)
                .select()
                .eq("id", value: id)
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
    
    func createItemState(itemState: ItemState) async -> RepositoryResult<ItemStateDTO> {
        let itemStateDTO = ItemStateDTO(
            id: itemState.id,
            workspaceId: itemState.workspaceId,
            indexKey: itemState.indexKey,
            name: itemState.name,
            color: itemState.color.rawValue,
            createdAt: Date(),
            updatedAt: nil
        )
        do {
            let response: ItemStateDTO = try await client
                .from(table)
                .insert(itemStateDTO)
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
    
    func updateItemState(id: UUID, itemState: ItemState) async -> RepositoryResult<Void> {
        let itemStateDTO = ItemStateDTO(
            id: itemState.id,
            workspaceId: itemState.workspaceId,
            indexKey: itemState.indexKey,
            name: itemState.name,
            color: itemState.color.rawValue,
            createdAt: nil,
            updatedAt: Date()
        )
        do {
            _ = try await client
                .from(table)
                .update(itemStateDTO)
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
    
    func deleteItemState(id: UUID) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from(table)
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
                    .from(table)
                    .update(["index_key": "\(offest + i)"])
                    .eq("id", value: id)
                    .execute()
            }
            
            for (i, id) in order.enumerated() {
                try await client
                    .from(table)
                    .update(["index_key": i])
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
