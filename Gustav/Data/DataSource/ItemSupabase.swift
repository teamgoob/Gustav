//
//  ItemSupabase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/20.
//

import Foundation
import Supabase

// MARK: - ItemSupabase
// 아이템 원격 데이터 소스 구현체
final class ItemSupabase: ItemDataSourceProtocol {
    
    private let client: SupabaseClient
    private let table = "items"
    
    // 외부에서 SupabaseClient 주입
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // 워크스페이스 내 전체 아이템 목록 조회 (기본)
    func fetchItems(workspaceId: UUID, pagination: Pagination?) async -> RepositoryResult<[ItemDTO]> {
        do {
            // 기본 쿼리 생성
            var query = client
                .from(table)
                .select()
                .eq("workspace_id", value: workspaceId)
                .is("deleted_at", value: nil)
                .order("index_key", ascending: true)
            
            // 페이지 정보 적용
            if let pagination = pagination {
                query = query.range(
                    from: pagination.offset,
                    to: pagination.offset + pagination.limit - 1
                )
            }
            
            // 결과 반환
            let response: [ItemDTO] = try await query.execute().value
            return .success(response)
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }
    
    // 워크스페이스 내 조건 기반 아이템 조회
    func queryItems(workspaceId: UUID, query: ItemQuery, pagination: Pagination?) async -> RepositoryResult<[ItemDTO]> {
        do {
            // 기본 쿼리 생성
            var supabaseQuery = client
                .from(table)
                .select()
                .eq("workspace_id", value: workspaceId)
                .is("deleted_at", value: nil)
            
            // 필터 옵션 적용
            for filter in query.filters {
                switch filter {
                case .category(let categoryId):
                    // 해당 카테고리를 부모 카테고리로 두는 모든 하위 카테고리 조회
                    let categoryDtos: [CategoryIdDTO] = try await client
                        .rpc("get_subcategory", params: ["category_uuid": categoryId])
                        .execute()
                        .value
                    // UUID 배열로 변환
                    let categoryIds: [UUID] = categoryDtos.map { $0.id }
                    // 조회한 카테고리 목록을 쿼리 조건에 추가
                    supabaseQuery = supabaseQuery
                        .in("category_id", values: categoryIds)
                    
                case .itemState(let itemStateId):
                    supabaseQuery = supabaseQuery
                        .eq("state_id", value: itemStateId)
                    
                case .location(let locationId):
                    supabaseQuery = supabaseQuery
                        .eq("location_id", value: locationId)
                }
            }
            
            // 검색 옵션 적용
            if let text = query.searchText,
               !text.trimmingCharacters(in: .whitespaces).isEmpty {
                let pattern = "%\(text)%"
                
                // name or name_detail 검색
                supabaseQuery = supabaseQuery.or(
                    "name.ilike.\(pattern),name_detail.ilike.\(pattern)"
                )
            }
            
            // 정렬 옵션 적용
            var orderedQuery: PostgrestTransformBuilder
            
            if let sortOption = query.sortOption {
                switch sortOption {
                case .indexKey(let order):
                    orderedQuery = supabaseQuery
                        .order("index_key", ascending: order == .ascending)
                    
                case .name(let order):
                    orderedQuery = supabaseQuery
                        .order("name", ascending: order == .ascending)
                    
                case .nameDetail(let order):
                    orderedQuery = supabaseQuery
                        .order("name_detail", ascending: order == .ascending)
                    
                case .purchaseDate(let order):
                    orderedQuery = supabaseQuery
                        .order("purchase_date", ascending: order == .ascending)
                    
                case .purchasePlace(let order):
                    orderedQuery = supabaseQuery
                        .order("purchase_place", ascending: order == .ascending)
                    
                case .expireDate(let order):
                    orderedQuery = supabaseQuery
                        .order("warranty_expire_at", ascending: order == .ascending)
                    
                case .price(let order):
                    orderedQuery = supabaseQuery
                        .order("price", ascending: order == .ascending)
                    
                case .quantity(let order):
                    orderedQuery = supabaseQuery
                        .order("quantity", ascending: order == .ascending)
                    
                case .createdAt(let order):
                    orderedQuery = supabaseQuery
                        .order("created_at", ascending: order == .ascending)
                    
                case .updatedAt(let order):
                    orderedQuery = supabaseQuery
                        .order("updated_at", ascending: order == .ascending)
                }
            } else {
                // 기본 정렬
                orderedQuery = supabaseQuery.order("index_key", ascending: true)
            }
            
            // 페이지 정보 적용
            if let pagination = pagination {
                orderedQuery = orderedQuery.range(
                    from: pagination.offset,
                    to: pagination.offset + pagination.limit - 1
                )
            }
            
            // 결과 반환
            let response: [ItemDTO] = try await orderedQuery.execute().value
            return .success(response)
        } catch {
            // 에러 타입에 따라 Repository Error로 매핑하여 반환
            if let e = error as? RepositoryErrorConvertible {
                return .failure(e.mapToRepositoryError())
            }
            
            return .failure(.unknown)
        }
    }

    
    // 아이템 생성
    func createItem(workspaceId: UUID, item: Item) async -> RepositoryResult<ItemDTO> {
        do {
            // ItemDTO 생성
            let dto = ItemDTO(
                id: item.id,
                workspaceId: workspaceId,
                indexKey: item.indexKey,
                name: item.name,
                nameDetail: item.nameDetail,
                categoryId: item.categoryId,
                stateId: item.stateId,
                locationId: item.locationId,
                purchaseDate: item.purchaseDate,
                purchasePlace: item.purchasePlace,
                warrantyExpireAt: item.warrantyExpireAt,
                price: item.price,
                quantity: item.quantity,
                memo: item.memo,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                deletedAt: nil
            )
            
            // 결과 반환
            let response: ItemDTO = try await client
                .from(table)
                .insert(dto)
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
    
    // 아이템 수정
    func updateItem(id: UUID, item: Item) async -> RepositoryResult<Void> {
        do {
            // ItemDTO 생성
            let dto = ItemDTO(
                id: item.id,
                workspaceId: item.workspaceId,
                indexKey: item.indexKey,
                name: item.name,
                nameDetail: item.nameDetail,
                categoryId: item.categoryId,
                stateId: item.stateId,
                locationId: item.locationId,
                purchaseDate: item.purchaseDate,
                purchasePlace: item.purchasePlace,
                warrantyExpireAt: item.warrantyExpireAt,
                price: item.price,
                quantity: item.quantity,
                memo: item.memo,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                deletedAt: nil
            )
            
            // ItemDTO를 활용하여 수정
            try await client
                .from(table)
                .update(dto)
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
    
    // 아이템 삭제
    func deleteItem(id: UUID) async -> RepositoryResult<Void> {
        do {
            // 아이템 삭제용 DTO 생성
            let dto = ItemDeleteDTO(index_key: 10_000, deleted_at: Date())
            
            // DTO를 활용하여 수정
            try await client
                .from(table)
                .update(dto)
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
    
    // 아이템 순서 변경
    func reorderItems(workspaceId: UUID, order: [UUID]) async -> RepositoryResult<Void> {
        do {
            let params = ItemReorderParams(p_workspace_id: workspaceId, p_order: order)
            try await client
                .rpc("reorder_items", params: params)
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

// 전체 하위 카테고리 조회 RPC 수행 결과를 저장하기 위한 DTO 선언
private extension ItemSupabase {
    struct CategoryIdDTO: Codable {
        let id: UUID
    }
}
