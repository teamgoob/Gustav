//
//  CategorySupabase.swift
//  Gustav
//
//  Created by 박선린 on 2/12/26.
//
import Foundation
import Supabase

final class SupabaseLocationRemoteDataSource: LocationDataSourceProtocol {
    // 클라이언트
    private let client: SupabaseClient
    
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetchLocations(workspaceId: UUID) async -> RepositoryResult<[LocationDTO]> {
        do {
            let response = try await client
                .from("locations")
                .select()
                .eq("workspace_id", value: workspaceId)
                .order("index_key")
                .execute()
            let data = response.data
            do {
                let locations = try JSONDecoder().decode([LocationDTO].self, from: data)
                return .success(locations)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("fetchCategories Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func fetchLocation(id: UUID) async -> RepositoryResult<LocationDTO?> {
        do {
            let response = try await client
                .from("location")
                .select()
                .eq("id", value: id)
                .execute()
            let data = response.data
            do {
                let location = try JSONDecoder().decode(LocationDTO.self, from: data)
                return .success(location)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func createLocation(dto: LocationDTO) async -> RepositoryResult<LocationDTO> {
        do {
            let response = try await client
                .from("locations")
                .insert(dto)
                .select()
                .single()
                .execute()
            let data = response.data
            do {
                let location = try JSONDecoder().decode(LocationDTO.self, from: data)
                return .success(location)
            } catch {
                return .failure(RepositoryError.decoding)
            }
        } catch {
            return .failure(RepositoryError.unknown)    // 임시
        }
    }
    
    func updateLocation(id: UUID, dto: LocationDTO) async -> RepositoryResult<Void> {
        do {
            let response = try await client
                .from("locations")
                .update(dto)
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            return .failure(RepositoryError.unknown)    //임시
        }
    }
    
    func deleteLocation(id: UUID) async -> RepositoryResult<Void> {
        do {
            _ = try await client
                .from("locations")
                .delete()
                .eq("id", value: id)
                .execute()
            return .success(())
        } catch {
            return .failure(RepositoryError.unknown) //임시
        }
    }
    
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        let offest = 10_000
        do {
            for (i, id) in order.enumerated() {
                try await client
                    .from("locations")
                    .update(["index_key": "\(offest + i)"])
                    .eq("id", value: id)
                    .execute()
            }
            
            for (i, id) in order.enumerated() {
                try await client
                    .from("locations")
                    .update(["index_key": i])
                    .eq("id", value: id)
                    .execute()
            }
            
        } catch {
            return .failure(RepositoryError.decoding)   // 임시
        }
    }
    
    func fetchNextIndexKey(workspaceId: UUID) async -> RepositoryResult<Int> {
        do {
            let result: IndexKeyDTO = try await client
                .from("location")
                .select("index_key")
                .eq("workspace_id", value: workspaceId)
                .order("index_key", ascending: false)
                .limit(1)
                .single()
                .execute()
                .value
            
            return .success(result.index_key + 1)
        } catch let error as PostgrestError {
            if error.code == "PGRST116" {
                return .success(0)
            }
        } catch {
                return .failure(RepositoryError.decoding)   // 임시
        }
    }
}
