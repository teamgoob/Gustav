//
//  WorkspaceContextUsecase.swift
//  Gustav
//
//  Created by 최명수 on 2026/2/9.
//

import Foundation

// MARK: - WorkspaceContext를 불러오는 Usecase
protocol WorkspaceContextUsecaseProtocol {
    // 워크스페이스 정보 조회 - Category / State / Location 포함
    func fetchContext(workspaceId: UUID) async -> DomainResult<WorkspaceContext>
}

final class WorkspaceContextUsecase: WorkspaceContextUsecaseProtocol {
    
    
    private let workspaceRepo: WorkspaceRepositoryProtocol
    private let categoryRepo: CategoryRepositoryProtocol
    private let locationRepo: LocationRepositoryProtocol
    private let stateRepo: ItemStateRepositoryProtocol
    
    init(workspaceRepo: WorkspaceRepositoryProtocol, categoryRepo: CategoryRepositoryProtocol, locationRepo: LocationRepositoryProtocol, stateRepo: ItemStateRepositoryProtocol) {
        self.workspaceRepo = workspaceRepo
        self.categoryRepo = categoryRepo
        self.locationRepo = locationRepo
        self.stateRepo = stateRepo
    }
    
    func fetchContext(workspaceId: UUID) async -> DomainResult<WorkspaceContext> {
        // 1) workspace 단건 조회
        // 2) category 목록 조회
        // 3) location 목록 조회
        // 4) state 목록 조회
        // 5) 전부 성공하면 WorkspaceContext로 묶어서 반환
        
        
        // 병렬 요청
        async let workspaceR = workspaceRepo.fetchWorkspace(id: workspaceId)   // 단건 메서드 필요
        async let categoriesR = categoryRepo.fetchCategories(workspaceId: workspaceId)
        async let locationsR = locationRepo.fetchLocations(workspaceId: workspaceId)
        async let statesR = stateRepo.fetchItemStates(workspaceId: workspaceId)

        
        // 결과
        let w = await workspaceR.toDomainResult()
        let c = await categoriesR.toDomainResult()
        let l = await locationsR.toDomainResult()
        let s = await statesR.toDomainResult()
  

        // 실패 먼저 처리 (하나라도 실패면 종료)
        if case .failure(let e) = w { return .failure(e) }
        if case .failure(let e) = c { return .failure(e) }
        if case .failure(let e) = l { return .failure(e) }
        if case .failure(let e) = s { return .failure(e) }

        // 성공값 추출 (위에서 실패를 모두 걸렀으니 success 패턴만 남음)
        guard
            case .success(let workspace) = w,
            case .success(let categories) = c,
            case .success(let locations) = l,
            case .success(let states) = s
        else {
            assertionFailure("WorkspaceContextUsecase.fetchContext: unreachable state")
            return .failure(.unknown)
        }

        return .success(
            WorkspaceContext(
                workspace: workspace,
                categories: categories,
                locations: locations,
                states: states
            )
        )
    }
}
