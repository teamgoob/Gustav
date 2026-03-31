//
//  CategoryDetailViewModel.swift
//  Gustav
//
//  Created by 박선린 on 3/24/26.
//
import Foundation

final class LocationDetailViewModel {
    // Category
    private var location: Location
    
    // TagColorCases를 배열로 보관
    private let colors = TagColor.allCases
    
    // 선택한 TagColor case를 보관
    private var selectedColor: TagColor
    
    // Items
    private var items: [Item] = []
    
    // Usecases
    private let itemQueryUseCase: ItemQueryUsecaseProtocol
    private let locationUseCase: LocationUsecaseProtocol
    
    // VC가 구독(바인딩)할 콜백
    var onStateChange: ((State) -> Void)?
    
    // 화면 이동 이벤트 발생 시 Coordinator에 전달하여 화면 이동
    var onNavigation: ((Route) -> Void)?
    
    // 테스크 리모트
    var taskRemote: Task<Void, Error>?
    
    // MARK: - Init
    init(location: Location, locationUsecase: LocationUsecaseProtocol, itemQueryUsecase: ItemQueryUsecaseProtocol) {
        self.location = location
        self.selectedColor = location.color
        self.locationUseCase = locationUsecase
        self.itemQueryUseCase = itemQueryUsecase
    }
    
    // 다음 화면 경로
    enum Route {
        case startChangeName
        case reFetchLocationList
        case delete
        case showErrorAlert(String)
    }
    
    // 상태 전달
    enum State {
        case fetchedItems
        case changeTagColor
        case changeName(String)
        case delete
    }
    
    // 상태 전달 메서드
    func emit(_ state: State) {
        self.onStateChange?(state)
    }
    
    // MARK: - VC 혹은 Coordinator에서 전달 받을 요청 케이스
    enum Input {
        case viewDidLoad
        case didChangeTagColor(TagColor)
        case startChangeName
        case changedNameButton(String)
        case didTappedDeleteButton
    }
    
    func action(_ input: Input) {
        switch input {
        case .viewDidLoad:
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.fetchItems()
                emit(.fetchedItems)
            }
        case .didChangeTagColor(let tagColor):
            self.selectedColor = tagColor
            emit(.changeTagColor)
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.changeLocationColor(tagColor)
                onNavigation?(.reFetchLocationList)
            }
        case .startChangeName:
            onNavigation?(.startChangeName)
        case .changedNameButton(let name):
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.updateLocationName(name)
                onNavigation?(.reFetchLocationList)
            }
        case .didTappedDeleteButton:
            self.taskRemote?.cancel()
            self.taskRemote = Task {
                await self.deleteCategory()
                onNavigation?(.delete)
            }
        }
    }
    
    // Location Title 리턴
    func getLocationTitle() -> String {
        location.name
    }
    
    // TableView DataSource: 사용할 아이템 갯수
    func numberOfRows() -> Int {
        items.count
    }
    
    // TableView DataSource: TableView Cell에서 사용할 아이템
    func cellForRowAt(index: Int) -> Item {
        self.items[index]
    }
    
    // CollectionView DataSource
    func numberOfItems() -> Int {
        self.colors.count
    }
    
    // CollectionView DataSource
    func cellForItemAt(index: Int) -> TagColor {
        self.colors[index]
    }
    
    // CollectionView Delegate
    func getSelectedTagColor() -> TagColor {
        self.selectedColor
    }
    
    deinit {
        print("❌ LocationDetailViewModel deinit")
    }
    
}

private extension LocationDetailViewModel {
    // 아이템 쿼리
    private func fetchItems() async {
        // 쿼리 조건 생성
        let itemQuery = ItemQuery(
            sortOption: .createdAt(order: .ascending),
            filters: [.location(location.id)],
            searchText: nil
        )
        
        // Fetch
        let reult = await itemQueryUseCase
            .queryItems(
                workspaceId: self.location.workspaceId,
                query: itemQuery,
                pagination: nil
            )
        
        switch reult {
        case .success(let items):
            self.items = items
            emit(.fetchedItems)
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 카테고리 이름 변경
    private func updateLocationName(_ name: String) async {
        let updatedLocation = Location(
            id: location.id,
            workspaceId: location.workspaceId,
            indexKey: location.indexKey,
            name: name,
            color: location.color)
        
        let result = await locationUseCase.updateLocation(id: location.id, location: updatedLocation)
        
        switch result {
            case .success:
            self.location = updatedLocation
            emit(.changeName(name))
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 카테고리 테그 컬러 변경
    private func changeLocationColor(_ tagColor: TagColor) async {
        let updatedLocation = Location(
            id: location.id,
            workspaceId: location.workspaceId,
            indexKey: location.indexKey,
            name: location.name,
            color: tagColor
        )
        
        let result = await locationUseCase.updateLocation(id: location.id, location: updatedLocation )
        
        switch result {
            case .success:
            self.location = updatedLocation
            emit(.changeTagColor)
        case .failure(let error):
            self.selectedColor = location.color
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
    
    // 카테고리 삭제
    private func deleteCategory() async {
        let result = await locationUseCase.deleteLocation(id: self.location.id, workspaceId: self.location.workspaceId)
        switch result {
        case .success:
            emit(.delete)
        case .failure(let error):
            self.onNavigation?(.showErrorAlert(error.localizedDescription))
        }
    }
}
