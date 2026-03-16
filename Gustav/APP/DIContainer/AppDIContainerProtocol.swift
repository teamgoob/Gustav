//
//  AppDIContainerProtocol.swift
//  Gustav
//
//  Created by kaeun on 3/16/26.
//

import Foundation

protocol AppDIContainerProtocol {
    func makeAuthUseCase() -> AuthUseCaseProtocol
    func makeAuthDIContainer() -> AuthDIContainer
    func makeWorkspaceListDIContainer() -> WorkspaceListDIContainer
    func makeWorkspaceDIContainer(workspaceID: UUID) -> WorkspaceDIContainer
}
