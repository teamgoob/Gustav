//
//  TestCategoryUsecase.swift
//  Gustav
//
//  Created by 박선린 on 3/18/26.
//
import Foundation

final class TestCategoryUsecase: CategoryUsecaseProtocol {
    var database: [Category] =  [
        
        // MARK: - 최상위 카테고리
        Category(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: nil,
            indexKey: 0,
            name: "업무",
            color: .blue
        ),
        
        Category(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: nil,
            indexKey: 1,
            name: "개인",
            color: .green
        ),
        
        Category(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: nil,
            indexKey: 2,
            name: "학습",
            color: .orange
        ),
        
        
        // MARK: - 업무 하위
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 0,
            name: "기획",
            color: .purple
        ),
        
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 1,
            name: "개발",
            color: .red
        ),
        
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 2,
            name: "회의",
            color: .brown
        ),
        
        
        // MARK: - 개인 하위
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 0,
            name: "운동",
            color: .green
        ),
        
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 1,
            name: "취미",
            color: .pink
        ),
        
        
        // MARK: - 학습 하위
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 0,
            name: "iOS",
            color: .blue
        ),
        
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 1,
            name: "DB",
            color: .yellow
        ),
        
        Category(
            id: UUID(),
            workspaceId: UUID(uuidString: "ABCAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            parentId: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            indexKey: 2,
            name: "알고리즘",
            color: .darkGray
        )
    ]
    func fetchCategories(workspaceId: UUID) async -> DomainResult<[Category]> {
        return .success(database)
    }
    
    func createCategory(category: Category) async -> DomainResult<Category> {
        let newCategory = Category(
            id: category.id,
            workspaceId: category.workspaceId,
            parentId: category.parentId,
            indexKey: category.indexKey,
            name: category.name,
            color: category.color)
        
        database.append(newCategory)
        return .success(newCategory)
    }
    
    func updateCategory(id: UUID, category: Category) async -> DomainResult<Void> {
        let index = database.firstIndex { $0.id == id }
        if let index {
            database.remove(at: index)
            database.append(category)
            return .success(())
        }
        return .failure(.unknown)
    }
    
    func deleteCategory(id: UUID) async -> DomainResult<Void> {
        let index = database.firstIndex { $0.id == id }
        if let index {
            database.remove(at: index)
            return .success(())
        }
        return .failure(.unknown)
    }
    
    func reorderCategories(workspaceId: UUID, order: [UUID]) async -> DomainResult<Void> {
            var newCategories: [Category] = []
            var index: Int = 0
            for uuid in order {
                guard let  draftCategory = database.first(where: { $0.id == uuid }) else { return .failure(DomainError.unknown)}
                let newCategory = Category(
                    id: draftCategory.id,
                    workspaceId: draftCategory.workspaceId,
                    parentId: draftCategory.parentId,
                    indexKey: index,
                    name: draftCategory.name,
                    color: draftCategory.color
                )
                newCategories.append(newCategory)
                index += 1
            }
            self.database = newCategories
            return .success(())
    }
    
    
    
}
