//
//  WorkSpaceTestUsecase.swift
//  Gustav
//
//  Created by 박선린 on 3/5/26.
//

import Foundation

final class TestWorkSpaceUsecase: WorkspaceUsecaseProtocol {
    var database: [Workspace] = [
        
        Workspace(id: UUID(), userId: UUID(), indexKey: 0, name: "워크스페이스 1", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 1, name: "워크스페이스 2", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 2, name: "워크스페이스 3", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 3, name: "워크스페이스 4", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 4, name: "워크스페이스 5", createdAt: Date(), updatedAt: Date()),

        Workspace(id: UUID(), userId: UUID(), indexKey: 5, name: "워크스페이스 6", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 6, name: "워크스페이스 7", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 7, name: "워크스페이스 8", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 8, name: "워크스페이스 9", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 9, name: "워크스페이스 10", createdAt: Date(), updatedAt: Date()),

        Workspace(id: UUID(), userId: UUID(), indexKey: 10, name: "워크스페이스 11", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 11, name: "워크스페이스 12", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 12, name: "워크스페이스 13", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 13, name: "워크스페이스 14", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 14, name: "워크스페이스 15", createdAt: Date(), updatedAt: Date()),

        Workspace(id: UUID(), userId: UUID(), indexKey: 15, name: "워크스페이스 16", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 16, name: "워크스페이스 17", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 17, name: "워크스페이스 18", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 18, name: "워크스페이스 19", createdAt: Date(), updatedAt: Date()),
        Workspace(id: UUID(), userId: UUID(), indexKey: 19, name: "워크스페이스 20", createdAt: Date(), updatedAt: Date())

    ]
    func fetchWorkspaces() async -> DomainResult<[Workspace]> {
        return .success(database)
    }
    
    func createWorkspace(name: String) async -> DomainResult<Workspace> {
        let result = await fetchWorkspaces()
        switch result {
            case .success(let workspaces):
            let newIndexKey = workspaces.map(\.indexKey).max()! + 1
            let newWorkspace = Workspace(
                id: UUID(),
                userId: UUID(),
                indexKey: newIndexKey,
                name: name,
                createdAt: Date(),
                updatedAt: Date()
            )
            database.append(newWorkspace)
            return .success(newWorkspace)
        case .failure:
            return .failure(DomainError.authenticationRequired)
        }
    }
    
    func deleteWorkspace(id: UUID) async -> DomainResult<Void> {
        .success(())
    }
    
    func updateWorkspaceName(id: UUID, name: String) async -> DomainResult<Void> {
        for workspace in database {
            guard workspace.id == id else { continue }
            let changedWorkspace = Workspace(
                id: workspace.id,
                userId: workspace.userId,
                indexKey: workspace.indexKey,
                name: name,
                createdAt: workspace.createdAt,
                updatedAt: Date()
            )
            database[workspace.indexKey] = changedWorkspace
        }
        return .success(())
    }
    
    func reorderWorkspaces(order: [UUID]) async -> DomainResult<Void> {
        .success(())
    }
}
