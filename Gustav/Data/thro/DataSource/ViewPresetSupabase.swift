//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class SupabaseViewPresetRemoteDataSource: ViewPresetDataSourceProtocol {
    // 클라이언트
    private let client: SupabaseClient
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetchViewPresets(workspaceId: UUID) async -> RepositoryResult<[ViewPresetDTO]> {
        do {
            let response = try await client
                .from("view_presets")
                .select()
                .eq("workspace_id", value: workspaceId)
                .order("index_key")
                .execute()
            let data = response.data
            do {
                let presets = try JSONDecoder().decode([ViewPresetDTO].self, from: data)
                return .success(presets)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("fetchPresets Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func createViewPreset(workspaceId: UUID, dto: ViewPresetDTO) async -> RepositoryResult<ViewPresetDTO> {
        do {
            let reponse = try await client
                .from("view_presets")
                .insert(dto)
                .select()
                .single()
                .execute()
            let data = reponse.data
            do {
                let preset = try JSONDecoder().decode(ViewPresetDTO.self, from: data)
                return .success(preset)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func updateViewPreset(id: UUID, dto: ViewPresetDTO) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from("view_presets")
                .update(dto)
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func deleteViewPreset(id: UUID) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from("view_presets")
                .delete()
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
}
