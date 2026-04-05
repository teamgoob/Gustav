//
//  ViewPresetListViewModel.swift
//  Gustav
//
//  Created by kaeun on 3/20/26.
//

import Foundation

// MARK: - ViewPresetListViewModel
final class ViewPresetListViewModel {
    
    // MARK: - Item
    // 테이블뷰 셀 하나를 그리기 위한 화면용 데이터
    struct Item: Equatable {
        let id: UUID
        let title: String
        let subtitle: String // 날짜
    }
    
    // MARK: - Input
    enum Input {
        case viewDidLoad
        case viewWillAppear
        case didTapAddButton
        case didSelectItem(at: Int)
    }
    
    // MARK: - Output
    struct Output {
        let isLoading: LoadingState
        let itemCount: Int
    }
    
    // MARK: - Route
    enum Route {
        case pushToAddPreset
        case pushToPresetDetail(id: UUID)
    }
    
    // MARK: - Loading State
    enum LoadingState: Equatable {
        case loading(message: String)
        case notLoading
    }
    
    // MARK: - Closures
    var onDisplay: ((Output) -> Void)?
    var onNavigation: ((Route) -> Void)?
    
    // MARK: - Properties
    private(set) var items: [Item] = []
    private var isLoading: LoadingState = .notLoading
    private let viewPresetUsecase: ViewPresetUsecaseProtocol
    private let workspaceId: UUID
    
    // MARK: - Init
    init(viewPresetUsecase: ViewPresetUsecaseProtocol, workspaceId: UUID) {
        self.viewPresetUsecase = viewPresetUsecase
        self.workspaceId = workspaceId
    }
}

// MARK: - External Methods
extension ViewPresetListViewModel {
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            Task {
                await fetchPresets()
            }
        case .viewWillAppear:
            Task {
                await fetchPresets()
            }
        case .didTapAddButton:
            onNavigation?(.pushToAddPreset)
        case .didSelectItem(let index):
            handleSelection(at: index)
        }
    }
    
    var numberOfRows: Int {
        items.count
    }
    
    func rowItem(at row: Int) -> Item {
        items[row]
    }
}

// MARK: - Private Logic
private extension ViewPresetListViewModel {
    func fetchPresets() async {
        isLoading = .loading(message: "Loading Presets...")
        notifyOutput()
        
        let result = await viewPresetUsecase.fetchViewPresets(workspaceId: workspaceId)
        
        switch result {
        case .success(let presets):
            
            self.items = presets.map {
                let date = $0.updatedAt ?? $0.createdAt
                let subtitle = date.map { $0.formatDateyyyyMMdd() } ?? ""
                
                return Item(
                    id: $0.id,
                    title: $0.name,
                    subtitle: subtitle
                )
            }
        case .failure:
            self.items = []
        }
        
        isLoading = .notLoading
        notifyOutput()
    }
    
    func handleSelection(at index: Int) {
        guard items.indices.contains(index) else { return }
        onNavigation?(.pushToPresetDetail(id: items[index].id))
    }
    
    func notifyOutput() {
        let output = Output(
            isLoading: isLoading,
            itemCount: items.count
        )
        
        DispatchQueue.main.async {
            self.onDisplay?(output)
        }
    }
}
