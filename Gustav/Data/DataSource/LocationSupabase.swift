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
    private let table = "locations"
    // 생성자
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetchLocations(workspaceId: UUID) async -> RepositoryResult<[LocationDTO]> {
        do {
            let response: [LocationDTO] = try await client
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
    
    func fetchLocation(id: UUID) async -> RepositoryResult<LocationDTO> {
        do {
            let response: LocationDTO = try await client
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
    
    func createLocation(location: Location) async -> RepositoryResult<LocationDTO> {
        let locationDTO = LocationDTO(
            id: location.id,
            workspaceId: location.workspaceId,
            indexKey: location.indexKey,
            name: location.name,
            color: location.color.rawValue,
            createdAt: Date(),
            updatedAt: nil
        )
        do {
            let response: LocationDTO = try await client
                .from(table)
                .insert(locationDTO)
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
    
    func updateLocation(id: UUID, location: Location) async -> RepositoryResult<Void> {
        let locationDTO = LocationDTO(
            id: location.id,
            workspaceId: location.workspaceId,
            indexKey: location.indexKey,
            name: location.name,
            color: location.color.rawValue,
            createdAt: nil,
            updatedAt: Date()
        )
        do {
            _ = try await client
                .from(table)
                .update(locationDTO)
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
    
    func reorderLocations(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
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
