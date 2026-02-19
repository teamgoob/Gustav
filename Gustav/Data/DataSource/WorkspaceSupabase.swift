//
//  WorkspaceSupabase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/19.
//

import Foundation
import Supabase

// MARK: - WorkspaceSupabase
// 워크스페이스 원격 데이터 소스 구현체
final class WorkspaceSupabase: WorkspaceDataSourceProtocol {
    
    private let client: SupabaseClient
    private let table = "workspaces"
    
    // 외부에서 SupabaseClient 주입
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // 워크스페이스 목록 조회
    func fetchWorkspaces(userId: UUID) async -> RepositoryResult<[WorkspaceDTO]> {
        do {
            let response: [WorkspaceDTO] = try await client
                .from(table)
                .select()
                .eq("user_id", value: userId)
                .order("index_key", ascending: true)
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
    
    // 단일 워크스페이스 조회
    func fetchWorkspace(id: UUID) async -> RepositoryResult<WorkspaceDTO> {
        do {
            let response: [WorkspaceDTO] = try await client
                .from(table)
                .select()
                .eq("id", value: id)
                .limit(1)
                .execute()
                .value
            
            guard let dto = response.first else {
                return .failure(.notFound)
            }
            
            return .success(dto)
            
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
    
    // 워크스페이스 생성
    func createWorkspace(userId: UUID, name: String) async -> RepositoryResult<WorkspaceDTO> {
        do {
            // 현재 워크스페이스 목록의 마지막 인덱스 조회
            let lastValue: [WorkspaceDTO] = try await client
                .from(table)
                .select("index_key")
                .eq("user_id", value: userId)
                .order("index_key", ascending: false)
                .limit(1)
                .execute()
                .value
            
            // 다음 인덱스 값 계산
            let nextIndex = (lastValue.first?.indexKey ?? -1) + 1
            
            // 새로운 워크스페이스 생성
            let newWorkspace = WorkspaceDTO(
                id: UUID(),
                userId: userId,
                indexKey: nextIndex,
                name: name,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // 워크스페이스 테이블에 추가
            let inserted: WorkspaceDTO = try await client
                .from(table)
                .insert(newWorkspace)
                .select()
                .single()
                .execute()
                .value
            
            return .success(inserted)
            
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
    
    // 워크스페이스 이름 수정
    func updateWorkspaceName(id: UUID, name: String) async -> RepositoryResult<Void> {
        do {
            try await client
                .from(table)
                .update(["name": name])
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
    
    // 워크스페이스 삭제
    func deleteWorkspace(id: UUID) async -> RepositoryResult<Void> {
        do {
            try await client
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
    
    // 워크스페이스 순서 변경
    func reorderWorkspaces(userId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        do {
            let params = WorkspaceReorderParams(p_user_id: userId, p_order: order)
            try await client
                .rpc("reorder_workspaces", params: params)
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
