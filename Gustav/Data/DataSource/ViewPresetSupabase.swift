//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class ViewPresetSupabase: ViewPresetDataSourceProtocol {
    // 클라이언트
    private let client: SupabaseClient
    private let table = "view_presets"
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetchViewPresets(workspaceId: UUID) async -> RepositoryResult<[ViewPresetDTO]> {
        do {
            let response: [ViewPresetDTO] = try await client
                .from(table)
                .select()
                .eq("workspace_id", value: workspaceId)
                .order("created_at", ascending: false)
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
    
    func createViewPreset(workspaceId: UUID, viewPreset: ViewPreset) async -> RepositoryResult<ViewPresetDTO> {
        let entity = ViewPreset(
            id: viewPreset.id,
            workspaceId: workspaceId,
//            indexKey: viewPreset.indexKey,
            name: viewPreset.name,
            viewType: viewPreset.viewType,
            sortingOption: viewPreset.sortingOption,
            filters: viewPreset.filters,
            createdAt: Date(),
            updatedAt: nil
        )
        let viewPresetDTO = ViewPresetMapper.toDTO(from: entity)
        do {
            let response: ViewPresetDTO = try await client
                .from(table)
                .insert(viewPresetDTO)
                .select()
                .single()
                .execute()
                .value
            return .success(response)
        } catch {
            print("createViewPreset error:", error)
            print("localized:", error.localizedDescription)

            if let e = error as? PostgrestError {
                print("message:", e.message)
                print("detail:", e.detail ?? "")
                print("hint:", e.hint ?? "")
                print("code:", e.code ?? "")
            }
            
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            return .failure(.unknown)
        }
    }
    
    func updateViewPreset(id: UUID, viewPreset: ViewPreset) async -> RepositoryResult<Void> {
        let entity = ViewPreset(
            id: viewPreset.id,
            workspaceId: viewPreset.workspaceId,
//            indexKey: viewPreset.indexKey,
            name: viewPreset.name,
            viewType: viewPreset.viewType,
            sortingOption: viewPreset.sortingOption,
            filters: viewPreset.filters,
            createdAt: nil,
            updatedAt: Date()
        )
        let viewPresetDTO = ViewPresetMapper.toDTO(from: entity)
        do {
            _ = try await client
                .from(table)
                .update(viewPresetDTO)
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
    
    func deleteViewPreset(id: UUID) async -> RepositoryResult<Void> {
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
}
